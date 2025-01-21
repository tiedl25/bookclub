import 'dart:async';
import 'dart:typed_data';

import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/comment.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/models/progress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:synchronized/synchronized.dart';

class DatabaseHelper {
  //Singleton Pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static SupabaseClient? _database;
  Future<SupabaseClient> get database async => _database ??= await _initDatabase();

  static var lock = Lock(reentrant: true);

  Future<SupabaseClient> _initDatabase() async {
    await Supabase.initialize(
      url: 'https://supabase.tiedl.rocks',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE',
    );

    return Supabase.instance.client;
  }

  addBook(Book book) async {
    await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return await db.from('books').insert(book.toMap());
    });
  }

  Future<Book> getBook(int id) async {
    var response = await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return (await db.from('books').select().eq('id', id))[0];
    });

    if (response.isNotEmpty) {
      return Book.fromMap(response);
    } else {
      throw Exception('Book not found');
    }
  }

  Future<List<Book>> getBookList() async {
    var response = await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return (await db.from('books').select().order('id', ascending: true));
    });

    return response.isNotEmpty ? List.generate(response.length, (index) => Book.fromMap(response[index])) : [];
  }

  Future<Book?> getCurrentBook() async {
    return await lock.synchronized(() async {
      SupabaseClient db = await instance.database;

      DateTime now = DateTime.now();

      final currentBook = (await db.from('books').select().gte('to', now.toIso8601String()).lte('from', now.toIso8601String()));

      return currentBook.isNotEmpty ? Book.fromMap(currentBook[0]) : null;
    });
  }

  addMember(Member member) async {
    await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return await db.from('members').insert(member.toMap());
    });
  }

  Future<Member> getMember(int id) async {
    var response = await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return (await db.from('members').select().eq('id', id))[0];
    });

    if (response.isNotEmpty) {
      return Member.fromMap(response)
        ..profilePicture = await getProfilePicture(id);
    } else {
      throw Exception('Member not found');
    }
  }

  Future<List<Member>> getMemberList() async {
    var response = await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return (await db.from('members').select().order('id', ascending: true));
    });

    List<Member> members = [];
    for (var i = 0; i < response.length; i++) {
      var member = Member.fromMap(response[i]);
      member.profilePicture = await getProfilePicture(response[i]['id']);
      members.add(member);
    }

    return response.isNotEmpty ? members : [];
  }

  Future<Uint8List?> getProfilePicture(int id) async {
    try{
      return await Supabase.instance.client.storage
        .from('public/profile_pictures') // Replace with your storage bucket name
        .download("$id.jpg");
    } catch (e) {
      return null;
    }
  }

  Future<List<Progress>> getProgressList([int? bookId]) async {
    var response = await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return bookId == null ? (await db.from('progress').select().order('member', ascending: true)) : (await db.from('progress').select().eq('book', bookId).order('member', ascending: true));
    });

    return response.isNotEmpty ? List.generate(response.length, (index) => Progress.fromMap(response[index])) : [];
  }

  updateMember(Member member) async {
    await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return await db.from('members').update(member.toMap()).eq('id', member.id!);
    });
  }

  updateProgress(Progress progress) async {
    await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return await db.from('progress').update(progress.toMap()).eq('id', progress.id!);
    });
  }

  updateComment(Comment comment) async {
    await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return await db.from('comments').update(comment.toMap()).eq('id', comment.id!);
    });
  }

  addComment(Comment comment) async {
    return await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return await db.from('comments').insert(comment.toMap()).select();
    });
  }

  deleteComment(int commentId) async {
    await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return await db.from('comments').delete().eq('id', commentId);
    });
  }

  Future<List<Comment>> getComments(int bookId) async {
    var response = await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return (await db.from('comments').select().eq('book', bookId).order('id', ascending: true));
    });

    return response.isNotEmpty ? List.generate(response.length, (index) => Comment.fromMap(response[index])) : [];
  }

  Future<List<String>> getFinishSentences() async {
    var response = await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return (await db.from('finishSentences').select().order('id', ascending: true));
    });

    return response.isNotEmpty ? List.generate(response.length, (index) => response[index]['text']) : [];
  }
}


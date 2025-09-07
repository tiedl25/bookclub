import 'dart:async';
import 'dart:typed_data';

import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/comment.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/models/progress.dart';
import 'package:bookclub/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:synchronized/synchronized.dart';

const adminEmail = 'admin@bookclub.com';
const memberEmail = 'member@bookclub.com';

class DatabaseHelper {
  //Singleton Pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static SupabaseClient? _database;
  Future<SupabaseClient> get database async => _database ??= await _initDatabase();

  static var lock = Lock(reentrant: true);

  Future<SupabaseClient> _initDatabase() async {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );

    return Supabase.instance.client;
  }

  Future<bool> checkLogin() async {
    final sb = await instance.database;
    return sb.auth.currentUser != null;
  }

  Future<bool> checkAdmin() async {
    final sb = await instance.database;
    return sb.auth.currentUser?.email == adminEmail;
  }

  addBook(Book book) async {
    await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      final response = await db.from('books').insert(book.toMap()).select('id').single();
      final id = response['id'];

      final members = await getMemberList();
      
      var progressFutures = <Future>[];
      for (var i = 0; i < members.length; i++) {
        progressFutures.add(db.from('progress').insert(Progress(
          bookId: id,
          memberId: members[i].id!,
          page: 0,
        ).toMap()));
      }

      await Future.wait(progressFutures);
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
      Member member = Member.fromMap(response[i]);
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

  updateBook(Book book) async {
    await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return await db.from('books').update(book.toMap()).eq('id', book.id!);
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

  Future<Result> loginWithPin(String enteredPin) async {
    AuthResponse? authResponse;

    try{
      authResponse = await Supabase.instance.client.auth.signInWithPassword(
        email: memberEmail,
        password: enteredPin,
      );
    } catch (e){
      e as AuthApiException;
      if (e.message == 'Invalid login credentials') {
        try{
          authResponse = await Supabase.instance.client.auth.signInWithPassword(
            email: adminEmail,
            password: enteredPin,
          );
        } catch (e){
          e as AuthApiException;
          if (e.message == 'Invalid login credentials') {
            return Result.failure(e.message);
          }
        }
      }
    }

    if (authResponse != null && authResponse.session != null) {
      final email = authResponse.user!.email;
      final role = (email == 'admin@bookclub.com') ? 'admin' : 'member';
      return Result.success("You are logged in as $role");
    } else {
      return Result.failure('Login failed');
    }
  }

}


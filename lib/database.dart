import 'dart:async';

import 'package:bookclub/models/book.dart';
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
      url: 'http://192.168.178.63:8000',
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

  Future<Book> getCurrentBook() async {
    var response = await lock.synchronized(() async {
      SupabaseClient db = await instance.database;

      DateTime now = DateTime.now();

      return (await db.from('books').select().gte('to', now.toIso8601String()).lte('from', now.toIso8601String()))[0];
    });

    if (response.isNotEmpty) {
      return Book.fromMap(response);
    } else {
      throw Exception('Book not found');
    }
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
      return Member.fromMap(response);
    } else {
      throw Exception('Member not found');
    }
  }

  Future<List<Member>> getMemberList() async {
    var response = await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return (await db.from('members').select());
    });

    return response.isNotEmpty ? List.generate(response.length, (index) => Member.fromMap(response[index])) : [];
  }

  Future<List<Progress>> getProgressList(int bookId) async {
    var response = await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return (await db.from('progress').select().eq('book', bookId));
    });

    return response.isNotEmpty ? List.generate(response.length, (index) => Progress.fromMap(response[index])) : [];
  }

  updateProgress(Progress progress) async {
    await lock.synchronized(() async {
      SupabaseClient db = await instance.database;
      return await db.from('progress').update(progress.toMap()).eq('id', progress.id!);
    });
  }
}


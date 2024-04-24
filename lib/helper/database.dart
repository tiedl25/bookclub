import 'dart:async';

import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/member.dart';
import 'package:synchronized/synchronized.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  //Singleton Pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  static var lock = Lock(reentrant: true);

  Future<Database> _initDatabase() async {
    String path = "/assets/db/bookclub.db";
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books(
        id INTEGER PRIMARY KEY,
        name TEXT,
        image BLOB,
        timestamp TEXT,
        member INTEGER,

        FOREIGN KEY (member) REFERENCES members (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE members(
        id INTEGER PRIMARY KEY,
        name TEXT,
        color INTEGER,
        timestamp TEXT,
      )
    ''');
    await db.execute('''
      CREATE TABLE progress(
        id INTEGER PRIMARY KEY,
        page INTEGER,
        rating INTEGER,
        member INTEGER,
        book INTEGER,

        FOREIGN KEY (member) REFERENCES members (id)
        FOREIGN KEY (book) REFERENCES books (id)
      )
    ''');
  }

  Future<List<Member>> getMembers([Database? db]) async {
    db = db ?? await instance.database;

    var members = await db.query('members', orderBy: 'id');
    List<Member> memberList = members.isNotEmpty ? members.map((e) => Member.fromMap(e)).toList() : [];

    return memberList;
  }

  Future <List<Book>> getBooks() async {
    Database db = await instance.database;
    var books = await db.query('splizz_items', orderBy: 'id');
    List<Book> booklist = books.isNotEmpty ? books.map((e) => Book.fromMap(e)).toList() : [];

    return booklist;
  }

  Future<Book> getBook(int id) async {
    Database db = await instance.database;
    Book book = await lock.synchronized(() async {
      var response = await db.query('books', orderBy: 'id', where: 'id = ?', whereArgs: [id]);
      Book item = (response.isNotEmpty ? (response.map((e) => Book.fromMap(e)).toList()) : [])[0];

      return item;
    });
    return book;
  }

  Future<int> addMember(Member member, [Database? db]) async {
    db = db ?? await instance.database;

    var map = member.toMap();
    return await db.insert('members', map);
  }

  updateMember(Member member) async {
    Database db = await instance.database;
    await db.update('item_members', member.toMap(), where: 'id = ?', whereArgs: [member.id]);
  }
}
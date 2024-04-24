import 'package:flutter/foundation.dart';

class Book{
  int? id;
  String name;
  Uint8List image;

  Book({this.id, required this.name, required this.image});

  Map<String, dynamic> toMap() => {
    'name': name,
    'id': id,
    'image': image,
  };

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      name: map['name'],
      image: map['image'],
    );
  }
}
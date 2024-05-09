class Book{
  int? id;
  String name;
  String author;
  int pages;
  String image_path;
  DateTime from;
  DateTime to;

  Book({this.id, required this.name, required this.image_path, required this.author, required this.pages, required this.from, required this.to});

  Map<String, dynamic> toMap() => {
    'name': name,
    'image_path': image_path,
    'author': author,
    'pages': pages,
  };

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      name: map['name'],
      image_path: map['image_path'],
      author: map['author'],
      pages: map['pages'],
      from: DateTime.parse(map['from']),
      to: DateTime.parse(map['to']),
    );
  }
}
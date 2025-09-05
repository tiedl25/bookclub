class Book{
  int? id;
  String? name;
  String? author;
  int? pages;
  String? imagePath;
  DateTime? from;
  DateTime? to;
  String? description;
  int? providerId;
  int? color;

  Book({this.id, required this.name, required this.imagePath, required this.author, required this.pages, required this.from, required this.to, required this.description, required this.providerId});


  Map<String, dynamic> toMap() => {
    'name': name,
    'image_path': imagePath,
    'author': author,
    'pages': pages,
    'from': from!.toIso8601String(),
    'to': to!.toIso8601String(),
    'description': description,
    'provider': providerId
  };

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      name: map['name'],
      imagePath: map['image_path'],
      author: map['author'],
      pages: map['pages'],
      from: DateTime.parse(map['from']),
      to: DateTime.parse(map['to']),
      description: map['description'],
      providerId: map['provider'],
    );
  }
}
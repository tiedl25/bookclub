class Progress{
  int? id;
  int page;
  int? rating;

  Progress({this.id, required this.page, this.rating});

  Map<String, dynamic> toMap() => {
    'id': id,
    'page': page,
    'rating': rating,
  };

  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      id: map['id'],
      page: map['page'],
      rating: map['rating'],
    );
  }
}
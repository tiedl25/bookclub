class Progress{
  int? id;
  int page;
  int? rating;
  String? review;
  int? bookId;
  int? memberId;
  int? maxPages;

  Progress({this.id, required this.page, this.rating, this.bookId, this.memberId, this.maxPages});

  Map<String, dynamic> toMap() => {
    'id': id,
    'page': page,
    'rating': rating,
    'book': bookId,
    'member': memberId,
    'maxPages': maxPages
  };

  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      id: map['id'],
      page: map['page'],
      rating: map['rating'],
      bookId: map['book'],
      memberId: map['member'],
      maxPages: map['maxPages']
    );
  }
}
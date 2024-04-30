class Progress{
  int? id;
  int page;
  int? rating;
  String? review;
  int? bookId;
  int? memberId;

  Progress({this.id, required this.page, this.rating, this.review, this.bookId, this.memberId});

  Map<String, dynamic> toMap() => {
    'id': id,
    'page': page,
    'rating': rating,
    'review': review,
    'book': bookId,
    'member': memberId
  };

  factory Progress.fromMap(Map<String, dynamic> map) {
    return Progress(
      id: map['id'],
      page: map['page'],
      rating: map['rating'],
      review: map['review'],
      bookId: map['book'],
      memberId: map['member']
    );
  }
}
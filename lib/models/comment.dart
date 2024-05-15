class Comment{
  int? id;
  String text;
  int? bookId;
  int? memberId;

  Comment({this.id, required this.text, this.bookId, this.memberId});

  Map<String, dynamic> toMap() => {
    'text': text,
    'book': bookId,
    'member': memberId
  };

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      text: map['text'],
      bookId: map['book'],
      memberId: map['member']
    );
  }
}
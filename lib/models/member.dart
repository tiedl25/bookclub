class Member{
  int? id;
  String name;

  Member({this.id, required this.name});

  Map<String, dynamic> toMap() => {
    'name': name,
    'id': id,
  };

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
    );
  }
}
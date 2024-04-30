class Member{
  int? id;
  String name;
  int color;

  Member({this.id, required this.name, required this.color});

  Map<String, dynamic> toMap() => {
    'name': name,
    'color': color,
  };

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      color: map['color'],
    );
  }
}
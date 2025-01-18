class Member{
  int? id;
  String name;
  int color;
  bool veto;

  Member({this.id, required this.name, required this.color, required this.veto});

  Map<String, dynamic> toMap() => {
    'name': name,
    'color': color,
    'veto': veto
  };

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      color: map['color'],
      veto: map['veto'],
    );
  }
}
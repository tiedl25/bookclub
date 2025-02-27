import 'dart:typed_data';

class Member{
  int? id;
  String name;
  int color;
  bool veto;
  Uint8List? profilePicture;
  DateTime birthDate;

  Member({this.id, required this.name, required this.color, required this.veto, this.profilePicture, required this.birthDate});

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
      birthDate: DateTime.parse(map['birthdate']),
    );
  }
}
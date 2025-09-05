import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/member.dart';

abstract class ProfileDialogState {
  Member member;

  ProfileDialogState({required this.member});

  ProfileDialogState copy();
}

class ProfileDialogLoading extends ProfileDialogState {
  ProfileDialogLoading({required super.member});

  @override
  ProfileDialogLoading copy() {
    return ProfileDialogLoading(member: member);
  }
}

class ProfileDialogLoaded extends ProfileDialogState {
  List<Book> books;

  ProfileDialogLoaded({required super.member, required this.books});

  @override
  ProfileDialogLoaded copy() {
    return ProfileDialogLoaded(member: member, books: books);
  }
}

class ProfileDialogError extends ProfileDialogState {
  final String message;

  ProfileDialogError({required this.message, required super.member});

  @override
  ProfileDialogError copy() {
    return ProfileDialogError(message: message, member: member);
  }
}


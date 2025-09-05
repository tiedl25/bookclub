import 'package:bookclub/bloc/profileDialog_states.dart';
import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class ProfileDialogCubit extends Cubit<ProfileDialogState> {
  Member member;

  ProfileDialogCubit({required this.member}) : super(ProfileDialogLoading(member: member)) {
    loadProfile(member);
  }

  void loadProfile(Member member) async {
    if (member.goodreadsId == null) {
      emit(ProfileDialogError(message: CustomStrings.profileDialogErrorNoGoodreadsId, member: member));
      return;
    }
    emit(ProfileDialogLoading(member: member));
    try {
      final books = await fetchBooksForMember(member);
      if (books.isEmpty) {
        emit(ProfileDialogError(message: CustomStrings.noOtherBooks, member: member));
      } else {
        emit(ProfileDialogLoaded(member: member, books: books));
      }
    } catch (e) {
      emit(ProfileDialogError(message: e.toString(), member: member));
    }
  }

  Future<List<Book>> fetchBooksForMember(Member member) async {
    final url = Uri.parse('https://api.allorigins.win/raw?url=https://www.goodreads.com/review/list_rss/${member.goodreadsId}?shelf=currently-reading');
    
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final xmlDocument = XmlDocument.parse(response.body);
      final bookElements = xmlDocument.findAllElements('item');
      final books = bookElements.map((element) {
        return Book.goodreads(
          name: element.findElements('title').single.text,
          author: element.findElements('author_name').single.text,
          pages: int.tryParse(element.findAllElements('num_pages').single.text) ?? 0,
          description: element.findElements('book_description').single.text,
          imagePath: element.findElements('book_medium_image_url').single.text,
        );
      }).toList();

      return books;
    } else {
      throw Exception("Failed to load books");
    }
  }
}
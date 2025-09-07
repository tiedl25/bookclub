import 'dart:math';

import 'package:bookclub/bloc/masterview_states.dart';
import 'package:bookclub/database.dart';
import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/comment.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/models/progress.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:bookclub/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class MasterViewCubit extends Cubit<MasterViewState> {
  final Function changeTheme;

  MasterViewCubit(this.changeTheme) : super(MasterViewLoading()) {
    fetchData();
  }

  int getProviderId(Book lastBook, List<Member> members) {
    final lastProviderId = lastBook.providerId;
    final sortedMembers = members;
    sortedMembers.sort((a, b) => b.birthDate.compareTo(a.birthDate));
    final lastProviderIndex = sortedMembers.indexWhere((element) => element.id == lastProviderId);
    return sortedMembers[lastProviderIndex+1].id!;
  }

  String compressedImagePath(String imagePath) {
    imagePath = imagePath.replaceAll("https://images-na.ssl-images-amazon.com/", "https://i.gr-assets.com/");
    imagePath = imagePath.replaceAll(".jpg", "._SY75_.jpg");

    return imagePath;
  }

  Future<Color?> getDominantColor(String? imagePath,[bool compressed = true]) async {
    if (imagePath == null) {
      return Colors.white;
    }

    if (compressed) {
      imagePath = compressedImagePath(imagePath);
    }

    final response = await http.get(Uri.parse(imagePath));

    if (response.statusCode != 200) {
      return Colors.white;
    }

    final imageProvider = Image.memory(response.bodyBytes).image;

    // Generate a palette from the image
    final paletteGenerator = await PaletteGenerator.fromImageProvider(imageProvider);

    // Return the dominant color
    return paletteGenerator.dominantColor?.color;
  }

  Future<void> fetchData() async {
    try {
      final login = await DatabaseHelper.instance.checkLogin();
      final admin = await DatabaseHelper.instance.checkAdmin();
      final members = await DatabaseHelper.instance.getMemberList();
      final books = await DatabaseHelper.instance.getBookList();
      final Book book = (await DatabaseHelper.instance.getCurrentBook()) ?? books.last;
      book.color ??= (await getDominantColor(book.imagePath) ?? Colors.white).toARGB32();
      final double nameMaxLength = members.map((e) => e.name.length).toList().reduce(max)*7;
      final List<String> finishSentences = await DatabaseHelper.instance.getFinishSentences();

      final comments = await DatabaseHelper.instance.getComments(book.id!);
      final progressList = await DatabaseHelper.instance.getProgressList(book.id!);

      if (books.last.from!.isBefore(DateTime.now())) {
        books.add(Book(
          id: -1,
          name: null,
          author: null,
          pages: null,
          imagePath: null,
          to: null,
          description: null,
          providerId: getProviderId(books.last, members),
          from: null,
          color: Colors.white.toARGB32(),
        ));
      }

      for (Book b in books) {
        if (b.color == null) {
          b.color = (await getDominantColor(b.imagePath) ?? Colors.white).toARGB32();
          await DatabaseHelper.instance.updateBook(b);
        }
        if (b.id == book.id) {
          b.color = book.color;
        }
      }

      final newState = MasterViewLoaded(
        login: login,
        admin: admin,
        members: members,
        books: books,
        book: book,
        nameMaxLength: nameMaxLength,
        finishSentences: finishSentences,
        comments: comments,
        progressList: progressList,
      );

      Future.wait(books.map((b) async {
        b.color = (await getDominantColor(b.imagePath) ?? Colors.white).toARGB32();
      })).then((_) => emit(newState..books = books));

      emit(newState);
    } catch (e) {
      // On error, emit the error state
      emit(MasterViewError(message: e.toString()));
    }
  }

  Future<void> toggleLogin() async {
    final newState = (state as MasterViewLoaded).copy();

    if (newState.login) {
      await Supabase.instance.client.auth.signOut();
      newState.login = false;
      newState.admin = false;
      emit(newState);
    } else {
      emit(MasterViewShowLoginDialog());
      emit(newState);
    }
  }

  Future<bool> login() async {
    final newState = (state as MasterViewLoaded).copy();

    Result result = await DatabaseHelper.instance.loginWithPin(newState.pinController.text);
    emit(MasterViewShowSnackBar(message: result.message ?? ''));
    
    if (result.isSuccess) {
      newState.login = true;
      newState.admin = await DatabaseHelper.instance.checkAdmin();
    }

    emit(newState);
    return result.isSuccess;
  }

  void toggleDescription(int bookId, bool isPhone) {
    final newState = (state as MasterViewLoaded).copy();

    if(bookId == newState.book.id){
      isPhone ? null : newState.showDescription = !newState.showDescription;
    }
    else {
      newState.showDescription = false;
      newState.carouselSliderController.animateToPage(bookId-1);
    }

    emit(newState);
  }

  Future<void> showDescriptionDialog(Book book, bool isPhone) async {
    final newState = (state as MasterViewLoaded).copy();

    if(book.id == newState.book.id){
      if (book.from != null) isPhone ? emit(MasterViewShowDescriptionDialog()) : newState.showDescription = !newState.showDescription;
    }
    else {
      newState.showDescription = false;
      if (newState.books.last != book) {
        newState.comments = await DatabaseHelper.instance.getComments(book.id!);
        newState.progressList = await DatabaseHelper.instance.getProgressList(book.id!);
      } else {
        newState.comments = [];
        newState.progressList = [];
      }

      newState.book = book;      
      newState.carouselSliderController.animateToPage(newState.books.indexWhere((element) => element.id == book.id!));
    }

    emit(newState);
  }

  void changePage(int index) async {
    final newState = (state as MasterViewLoaded).copy();

    newState.book = newState.books[index];
    newState.showDescription = false;

    if (newState.books.last != newState.book) {
      newState.comments = await DatabaseHelper.instance.getComments(newState.book.id!);
      newState.progressList = await DatabaseHelper.instance.getProgressList(newState.book.id!);
    } else {
      newState.comments = [];
      newState.progressList = [];
    }

    emit(newState);
  }

  Future<void> vote(bool? login, int voteButtonIndex) async {
    final newState = (state as MasterViewLoaded).copy();

    newState.login = login!;
    newState.admin = await DatabaseHelper.instance.checkAdmin();
    newState.members[voteButtonIndex].veto = !newState.members[voteButtonIndex].veto;
    DatabaseHelper.instance.updateMember(newState.members[voteButtonIndex]);

    emit(newState);
  }

  void showUpdateDialog(bool? login, Progress progress) async {
    final newState = MasterViewUpdateDialog.fromState(state as MasterViewLoaded, progress);

    newState.login = login!;
    newState.admin = await DatabaseHelper.instance.checkAdmin();

    emit(MasterViewShowUpdateDialog());
    emit(newState);
  }

  Future<void> updateProgress() async {
    final newState = (state as MasterViewUpdateDialog).copy();

    int oldPage = newState.progress.page;
    int nr = int.parse(newState.currentPageController.text);
    nr = nr < 0 ? 0 : nr;
    int maxNr = int.parse(newState.maxPagesController.text);
    newState.progress.page = nr > maxNr ? maxNr : nr;
    newState.progress.maxPages = maxNr < 1 ? 1 : maxNr;

    await DatabaseHelper.instance.updateProgress(newState.progress);

    if (newState.progress.page == (newState.progress.maxPages ?? newState.book.pages) && newState.progress.page != oldPage) {
      emit(MasterViewShowFinishDialog(finishSentences: newState.finishSentences));
    }

    emit(MasterViewLoaded.fromState(newState));
  }

  void closeUpdateDialog() {
    final newState = MasterViewLoaded.fromState(state);

    emit(newState);
  }

  Future<void> rate(bool? login, Progress progress, int bookRating) async {
    final newState = (state as MasterViewLoaded).copy();

    newState.login = login!;
    newState.admin = await DatabaseHelper.instance.checkAdmin();

    if (newState.progressList.firstWhere((element) => element.id == progress.id).rating == bookRating){
      newState.progressList.firstWhere((element) => element.id == progress.id).rating = 0;
    } else {
      newState.progressList.firstWhere((element) => element.id == progress.id).rating = bookRating;
    }

    await DatabaseHelper.instance.updateProgress(progress);

    emit(newState);
  }

  Future<void> addComment(bool? login, String text) async {
    if(text == ''){
      return;
    }

    final newState = (state as MasterViewLoaded).copy();

    newState.login = login!;
    newState.admin = await DatabaseHelper.instance.checkAdmin();

    final Comment newComment = Comment(text: text, bookId: newState.book.id!, memberId: newState.members.firstWhere((Member member) => member.id == newState.selectedMember).id!);

    final commentMap = await DatabaseHelper.instance.addComment(newComment);
    newState.comments.add(Comment.fromMap(commentMap[0]));
    emit(newState);
  }

  Future<void> updateComment(bool? login, String text, int i) async {
    final newState = (state as MasterViewLoaded).copy();

    newState.login = login!;
    newState.admin = await DatabaseHelper.instance.checkAdmin();

    newState.comments[i].text = text.replaceAll("‎", "");
    newState.comments[i].text = newState.comments[i].text.trim();
    if (newState.comments[i].text != '') {
      DatabaseHelper.instance.updateComment(Comment(id: newState.comments[i].id, text: newState.comments[i].text, bookId: newState.comments[i].bookId, memberId: newState.comments[i].memberId));
      newState.comments[i].editMode = !newState.comments[i].editMode;
    }

    emit(newState);
  }

  Future<void> deleteComment(Comment comment) async {
    final newState = (state as MasterViewLoaded).copy();

    DatabaseHelper.instance.deleteComment(comment.id!);
    newState.comments.remove(comment);

    emit(newState);
  }

  Future<void> updateLogin(bool? login) async {
    final newState = (state as MasterViewLoaded).copy();

    newState.login = login!;
    newState.admin = await DatabaseHelper.instance.checkAdmin();

    emit(newState);
  }

  Future<void> toggleEditMode(bool? login, int i) async {
    final newState = (state as MasterViewLoaded).copy();

    newState.login = login!;
    newState.admin = await DatabaseHelper.instance.checkAdmin();

    newState.comments[i].editMode = !newState.comments[i].editMode;

    emit(newState);
  }

  void selectMember(int? index) {
    final newState = (state as MasterViewLoaded).copy();

    newState.selectedMember = index ?? 1;

    emit(newState);
  }

  DateTimeRange getDateRange(Book lastBook) {
    DateTime startDate = lastBook.to!.add(const Duration(days: 1));
    DateTime endDate = DateTime(startDate.year, startDate.month + 3, 0);
    return DateTimeRange(start: startDate, end: endDate);
  }

  Future<void> addBook(GlobalKey<FormState> formKey, String title, String author, int pageNr, String description, String imagePath) async {
    if(!formKey.currentState!.validate()){
      MasterViewShowSnackBar(message: CustomStrings.addDialogValidationError);
    }

    final newState = (state as MasterViewLoaded).copy();

    DateTimeRange dateRange = getDateRange(newState.books[newState.books.length - 2]);
    int providerId = getProviderId(newState.books[newState.books.length - 2], newState.members);

    await DatabaseHelper.instance.addBook(
      Book(
        name: title,
        author: author,
        description: description,
        imagePath: imagePath,
        pages: pageNr,
        from: dateRange.start,
        to: dateRange.end,
        providerId: providerId,
        color: (await getDominantColor(imagePath) ?? Colors.white).toARGB32()
      )
    );

    formKey.currentState!.save();

    emit(newState);
  }
}
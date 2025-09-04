import 'dart:ui';

import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/comment.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/models/progress.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';

abstract class MasterViewState {
  MasterViewState();

  MasterViewState copy();
}

class MasterViewLoading extends MasterViewState {
  MasterViewLoading() : super();

  @override
  MasterViewLoading copy() {
    return MasterViewLoading();
  }
}

class MasterViewLoaded extends MasterViewState {
  bool admin;
  bool login;
  List<Member> members;
  List<Book> books;
  List<Comment> comments;
  List<Progress> progressList;
  Book book;
  double nameMaxLength;
  int selectedMember;
  List<String> finishSentences = [];
  bool showDescription;
  late CarouselSliderController carouselSliderController;
  late TextEditingController pinController;

  MasterViewLoaded({
    required this.admin,
    required this.login,
    required this.members,
    required this.books,
    required this.comments,
    required this.progressList,
    required this.book,
    required this.nameMaxLength,
    this.selectedMember = 1,
    this.showDescription = false,
    CarouselSliderController? carouselSliderController,
    TextEditingController? pinController,
    required this.finishSentences,
  }) : super() {
    this.carouselSliderController = carouselSliderController ?? CarouselSliderController();
    this.pinController = pinController ?? TextEditingController();
  }

  factory MasterViewLoaded.fromState(state) {
    return MasterViewLoaded(
      admin: state.admin,
      login: state.login,
      members: state.members,
      books: state.books,
      comments: state.comments,
      progressList: state.progressList,
      book: state.book,
      nameMaxLength: state.nameMaxLength,
      selectedMember: state.selectedMember,
      showDescription: state.showDescription,
      finishSentences: state.finishSentences,
      carouselSliderController: state.carouselSliderController,
      pinController: state.pinController,
    );
  }

  @override
  MasterViewLoaded copy() {
    return MasterViewLoaded(
      admin: admin,
      login: login,
      members: List.from(members),
      books: List.from(books),
      comments: List.from(comments),
      progressList: List.from(progressList),
      book: book,
      nameMaxLength: nameMaxLength,
      selectedMember: selectedMember,
      showDescription: showDescription,
      finishSentences: List.from(finishSentences),
      carouselSliderController: carouselSliderController,
      pinController: pinController,
    );
  }
}

class MasterViewUpdateDialog extends MasterViewLoaded {
  Progress progress;
  TextEditingController currentPageController;
  TextEditingController maxPagesController;

  MasterViewUpdateDialog({
    required this.progress,
    required super.admin,
    required super.login,
    required super.members,
    required super.books,
    required super.comments,
    required super.progressList,
    required super.book,
    required super.nameMaxLength,
    required super.selectedMember,
    required super.showDescription,
    required super.finishSentences,
    super.carouselSliderController,
    super.pinController,
    TextEditingController? currentPageController,
    TextEditingController? maxPagesController
  }) : currentPageController = currentPageController ?? TextEditingController(text: progress.page.toString())
        ..selection = TextSelection(baseOffset: 0, extentOffset: progress.page.toString().length),
       maxPagesController = maxPagesController ?? TextEditingController(text: (progress.maxPages ?? book.pages).toString());

  factory MasterViewUpdateDialog.fromState(MasterViewLoaded state, Progress progress) {
    return MasterViewUpdateDialog(
      progress: progress,
      admin: state.admin,
      login: state.login,
      members: state.members,
      books: state.books,
      comments: state.comments,
      progressList: state.progressList,
      book: state.book,
      nameMaxLength: state.nameMaxLength,
      selectedMember: state.selectedMember,
      showDescription: state.showDescription,
      finishSentences: state.finishSentences,
      carouselSliderController: state.carouselSliderController,
      pinController: state.pinController,
    );
  }

  @override
  MasterViewUpdateDialog copy() {
    return MasterViewUpdateDialog(
      progress: progress,
      admin: admin,
      login: login,
      members: members,
      books: books,
      comments: comments,
      progressList: progressList,
      book: book,
      nameMaxLength: nameMaxLength,
      selectedMember: selectedMember,
      showDescription: showDescription,
      finishSentences: finishSentences,
      carouselSliderController: carouselSliderController,
      pinController: pinController,
      currentPageController: currentPageController,
      maxPagesController: maxPagesController
    );
  }
}

class MasterViewError extends MasterViewState {
  final String message;

  MasterViewError({required this.message}) : super();

  @override
  MasterViewError copy() {
    return MasterViewError(message: message);
  }
}

abstract class MasterViewListener extends MasterViewState {
  MasterViewListener();
}

class MasterViewShowSnackBar extends MasterViewListener {
  final String message;

  MasterViewShowSnackBar({required this.message}) : super();

  @override
  MasterViewShowSnackBar copy() {
    return MasterViewShowSnackBar(message: message);
  }
}

class MasterViewShowLoginDialog extends MasterViewListener {
  String? title;

  MasterViewShowLoginDialog({this.title});

  @override
  MasterViewShowLoginDialog copy() {
    return MasterViewShowLoginDialog(title: title);
  }
}

class MasterViewShowUpdateDialog extends MasterViewListener {
  MasterViewShowUpdateDialog();

  @override
  MasterViewShowUpdateDialog copy() {
    return MasterViewShowUpdateDialog();
  }
}

class MasterViewShowFinishDialog extends MasterViewListener {
  List<String> finishSentences;

  MasterViewShowFinishDialog({required this.finishSentences});

  @override
  MasterViewShowFinishDialog copy() {
    return MasterViewShowFinishDialog(finishSentences: List.from(finishSentences));
  }
}

class MasterViewShowDescriptionDialog extends MasterViewListener {
  MasterViewShowDescriptionDialog();

  @override
  MasterViewShowDescriptionDialog copy() {
    return MasterViewShowDescriptionDialog();
  }
}
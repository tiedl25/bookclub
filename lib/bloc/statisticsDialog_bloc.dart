import 'package:bookclub/bloc/statisticsDialog_states.dart';
import 'package:bookclub/database.dart';
import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/member.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatisticsDialogCubit extends Cubit<StatisticsDialogState> {
  StatisticsDialogCubit(List<Book> books, List<Member> members) : super(StatisticsDialogLoading()) {
    loadStatistics(books, members);
  }

  void loadStatistics(List<Book> books, List<Member> members) async {
    try {
      final progressList = await DatabaseHelper.instance.getProgressList();

      emit(StatisticsDialogLoaded(
        progressList: progressList,
        books: books,
        members: members,
      ));
    } catch (e) {
      emit(StatisticsDialogError("Failed to load statistics"));
    }
  }

  Map<String, double> nominateShamePerson() {
    final newState = (state as StatisticsDialogLoaded).copy();

    Map<String, double> progressByMember = {};

    for (var member in newState.members){
      var memberProgress = newState.progressList.where((element) => element.memberId == member.id && element.bookId != newState.books.last.id);
      if (memberProgress.isNotEmpty){
        final parts = memberProgress.map((e) => e.page / (e.maxPages ?? newState.books.firstWhere((b) => b.id == e.bookId).pages!)).toList();
        double overalProgress = parts.reduce((element, value) => element + value) / parts.length;
        progressByMember[member.name] = overalProgress;
      }
    }
    return Map.fromEntries(progressByMember.entries.toList().where((e) => e.value < 1).toList()..sort((e1, e2) => e1.value.compareTo(e2.value)));
  }

  Map<Book, double> bookRatingList(){
    final newState = (state as StatisticsDialogLoaded).copy();

    Map<Book, double> ratingByBook = {};
    for (var book in newState.books){
      var bookProgress = newState.progressList.where((element) => element.bookId == book.id && element.rating != null && element.rating != 0 && element.page > 0);
      if (bookProgress.isNotEmpty){
        final parts = bookProgress.map((e) => e.rating ?? 0).toList();
        double overalRating = parts.reduce((element, value) => element + value) / parts.length;
        ratingByBook[book] = overalRating;
      }
    }
    //return Map.fromEntries(ratingByBook.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value)));
    return Map.fromEntries(ratingByBook.entries);
  }

  Map<Member, double> memberRatingList(){
    final newState = (state as StatisticsDialogLoaded).copy();

    Map<Member, double> ratingByMember = {};
    for (var member in newState.members){
      var memberProgress = newState.progressList.where((element) => element.memberId == member.id && element.rating != null && element.rating != 0 && element.page > 0);
      if (memberProgress.isNotEmpty){
        final parts = memberProgress.map((e) => e.rating ?? 0).toList();
        double overalRating = parts.reduce((element, value) => element + value) / parts.length;
        ratingByMember[member] = overalRating;
      }
    }
    //return Map.fromEntries(ratingByMember.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value)));
    return Map.fromEntries(ratingByMember.entries);
  }
}
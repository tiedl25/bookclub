import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/models/progress.dart';
import 'package:fl_heatmap/fl_heatmap.dart';

abstract class StatisticsDialogState {
  StatisticsDialogState();

  StatisticsDialogState copy();
}

class StatisticsDialogLoading extends StatisticsDialogState {
  StatisticsDialogLoading() : super();

  @override
  StatisticsDialogLoading copy() {
    return StatisticsDialogLoading();
  }
}

class StatisticsDialogLoaded extends StatisticsDialogState {
  List<Progress> progressList;
  List<Book> books;
  List<Member> members;
  HeatmapItem? selectedItem;

  StatisticsDialogLoaded(
      {
        this.progressList = const [],
        this.books = const [],
        this.members = const [],
        this.selectedItem,
      }
  );

  @override
  StatisticsDialogLoaded copy() {
    return StatisticsDialogLoaded(
      progressList: List.from(progressList),
      books: List.from(books),
      members: List.from(members),
      selectedItem: selectedItem,
    );
  }
}

class StatisticsDialogError extends StatisticsDialogState {
  String message;

  StatisticsDialogError(this.message);

  @override
  StatisticsDialogError copy() {
    return StatisticsDialogError(message);
  }
}
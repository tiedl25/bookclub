import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bookclub/bloc/masterview_bloc.dart';
import 'package:bookclub/bloc/masterview_states.dart';
import 'package:bookclub/bloc/statisticsDialog_bloc.dart';
import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/dialogs/updateDialog.dart';
import 'package:bookclub/dialogs/statisticsDialog.dart';
import 'package:bookclub/dialogs/commentDialog.dart';
import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:bookclub/utils.dart';
import 'package:bookclub/widgets/bookCarousel.dart';
import 'package:bookclub/widgets/progressTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MasterView extends StatelessWidget {
  late BuildContext context;
  late MasterViewCubit cubit;

  late double aspRat;
  late Book book;
  late List<Member> members;

  int get daysLeft => book.to!.difference(DateTime.now()).inDays + 1;
  int get minimumPages => (book.pages! /
          book.from!.difference(book.to!).inDays *
          book.from!.difference(DateTime.now()).inDays)
      .toInt();
  String get bookInfo =>
      '${book.name} von ${book.author} - ${book.pages} Seiten';
  String get bookDaysLeft =>
      'Du hast noch $daysLeft Tag${daysLeft > 1 ? 'e' : ''} um das Buch zu lesen. Die Zeit rennt!!!';
  String get bookMinPages =>
      'Seite $minimumPages sollte jetzt schon drin sein.';
  String get bookProvider => !defaultBook(book.from)
      ? '${members.firstWhere((m) => m.id == book.providerId).name} hat das Buch ausgesucht'
      : 'Als nächstes muss ${members.firstWhere((m) => m.id == book.providerId).name} ein Buch auswählen';

  bool get phone => aspRat < 1 ? true : false;

  bool defaultBook(DateTime? date) => date == null;
  bool get futureBook =>
      book.from == null || book.from!.isAfter(DateTime.now());

  String randomFinishSentence(List<String> finishSentences) {
    return finishSentences[Random().nextInt(finishSentences.length)];
  }

  Widget content(MasterViewLoaded state) {
    book = state.book;
    members = state.members;

    return Center(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 70,
          child: Column(children: [
            const Spacer(flex: 1),
            Column(children: [
              BlocProvider.value(
                value: cubit,
                child: BookCarousel(aspRat: aspRat, isPhone: phone),
              ),
              const SizedBox(
                height: 10,
              ),
              //const Spacer(flex: 1),
              if (!defaultBook(state.book.from))
                AutoSizeText(
                  bookInfo,
                  textAlign: TextAlign.center,
                  minFontSize: 18,
                ),
              if (!futureBook)
                if (daysLeft > 0)
                  AutoSizeText(
                    bookDaysLeft,
                    textAlign: TextAlign.center,
                    minFontSize: 18,
                  ),
              if (!futureBook)
                if (daysLeft > 0)
                  AutoSizeText(
                    bookMinPages,
                    textAlign: TextAlign.center,
                    minFontSize: 18,
                  ),
              AutoSizeText(
                bookProvider,
                textAlign: TextAlign.center,
                minFontSize: 16,
              ),
              if (futureBook && state.members.every((e) => e.veto))
                const AutoSizeText(
                  CustomStrings.veto,
                  textAlign: TextAlign.center,
                  minFontSize: 14,
                ),
              if (futureBook && !state.members.every((e) => e.veto))
                const AutoSizeText(
                  CustomStrings.vetoInfo,
                  textAlign: TextAlign.center,
                  minFontSize: 14,
                ),
            ]),
            const Divider(),
            Expanded(
                flex: 20,
                child: !futureBook ? memberBoard(state) : votingBoard()),
          ]),
        ),
        const VerticalDivider(),
        if (!phone)
          Expanded(
            flex: 20,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!phone)
                Expanded(
                  child: SizedBox(
                    child: SingleChildScrollView(
                      child: BlocProvider(
                        create: (context) =>
                            StatisticsDialogCubit(state.books, state.members),
                        child: StatisticsTile(),
                      ),
                    ),
                  ),
                ),
              if (!futureBook && !phone) const Divider(),
              //if (futureBook && !phone) const Spacer(flex: 40,),
              if (!futureBook && !phone)
                Expanded(
                  child: CommentTile(),
                ),
            ]),
          ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    this.cubit = BlocProvider.of<MasterViewCubit>(context);

    aspRat = MediaQuery.of(context).size.aspectRatio;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: phone
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Spacer(
                  flex: 3,
                ),
                FloatingActionButton(
                    mini: true,
                    //alignment: Alignment.bottomCenter,
                    onPressed: () {
                      if (!futureBook) {
                        showCommentDialog();
                      } else {
                        showOverlayMessage(
                            context: context,
                            message: CustomStrings.commentsNotAvailable);
                      }
                    },
                    child: const Icon(Icons.comment)),
                const Spacer(
                  flex: 1,
                ),
                FloatingActionButton(
                    mini: true,
                    //alignment: Alignment.bottomCenter,
                    onPressed: () {
                      showStatisticsDialog();
                    },
                    child: const Icon(Icons.bar_chart)),
                const Spacer(
                  flex: 3,
                )
              ])
            : null,
        body: BlocConsumer<MasterViewCubit, MasterViewState>(
            bloc: cubit,
            listenWhen: (_, current) => current is MasterViewListener,
            listener: (context, state) {
              switch (state.runtimeType) {
                case const (MasterViewShowLoginDialog):
                  showLoginDialog(cubit, context,
                      (state as MasterViewShowLoginDialog).title);
                  break;
                case const (MasterViewShowSnackBar):
                  showOverlayMessage(
                      context: context,
                      message: (state as MasterViewShowSnackBar).message);
                  break;
                case const (MasterViewShowFinishDialog):
                  showFinishDialog(
                      (state as MasterViewShowFinishDialog).finishSentences);
                  break;
                case const (MasterViewShowUpdateDialog):
                  showUpdateDialog();
                  break;
              }
            },
            buildWhen: (_, current) =>
                current.runtimeType == MasterViewLoaded ||
                current.runtimeType == MasterViewLoading,
            builder: (context, state) => state.runtimeType == MasterViewLoaded
                ? Stack(children: [
                    content(state as MasterViewLoaded),
                    topButtons(state)
                  ])
                : const Center(child: CircularProgressIndicator())));
  }

  Widget topButtons(MasterViewLoaded state) {
    return Positioned(
        right: 0,
        top: 0,
        child: Row(
          children: [
            if (state.login != null)
              IconButton(
                padding: const EdgeInsets.all(10),
                icon: state.login!
                    ? const Icon(Icons.login)
                    : const Icon(Icons.logout),
                onPressed: () => cubit.toggleLogin(),
              ),
            IconButton(
              padding: const EdgeInsets.all(10),
              icon: Theme.of(context).brightness == Brightness.dark
                  ? const Icon(Icons.light_mode)
                  : const Icon(Icons.dark_mode),
              onPressed: () => cubit.changeTheme(
                  (Theme.of(context).brightness == Brightness.dark)
                      ? ThemeMode.light
                      : ThemeMode.dark),
            ),
          ],
        ));
  }

  //Dialogs

  void showUpdateDialog() async {
    showDialog(
        context: context,
        builder: (builder) {
          return BlocProvider.value(
            value: cubit,
            child: UpdateDialog(),
          );
        }).then((value) => !value ? cubit.closeUpdateDialog() : null);
  }

  void showStatisticsDialog() {
    showDialog(
        context: context,
        builder: (builder) {
          return BlocProvider(
            create: (context) => StatisticsDialogCubit(
                (cubit.state as MasterViewLoaded).books,
                (cubit.state as MasterViewLoaded).members),
            child: StatisticsDialog(),
          );
        });
  }

  void showCommentDialog() {
    showDialog(
        context: context,
        builder: (builder) {
          return BlocProvider.value(
            value: cubit,
            child: CommentDialog(),
          );
        });
  }

  void showFinishDialog(List<String> finishSentences) {
    showDialog(
        context: context,
        builder: (builder) {
          return CustomDialog(
            title: const Text(CustomStrings.finishDialogTitle),
            content: Text(randomFinishSentence(finishSentences)),
          );
        });
  }

  //Widgets

  Widget votingBoard() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 500,
      ),
      child: GridView.builder(
        padding: EdgeInsets.only(
            top: 10, left: 10, right: 10, bottom: phone ? 70 : 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisExtent: 60,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            crossAxisCount: 2,
            childAspectRatio: 5 / 2),
        itemCount: members.length,
        itemBuilder: (context, i) => TextButton(
            style: TextButton.styleFrom(
                backgroundColor: members[i].veto
                    ? Color(members[i].color)
                    : Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
            onPressed: () async {
              bool? login = await showLoginDialog(cubit, context, CustomStrings.loginDialogTitle);
              if (!login!) return;
              cubit.vote(login, i);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundImage: members[i].profilePicture != null
                      ? MemoryImage(members[i].profilePicture!)
                          as ImageProvider<Object>
                      : const AssetImage('assets/images/pp_placeholder.jpeg'),
                ),
                const SizedBox(width: 10),
                Text(
                  members[i].name,
                  style: TextStyle(
                      color: members[i].veto
                          ? Colors.black
                          : Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            )),
      ),
    );
  }

  Widget memberBoard(state) {
    return ListView.builder(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.only(
            left: 10, right: 10, top: 10, bottom: phone ? 70 : 10),
        itemCount: state.progressList.length,
        itemBuilder: (context, i) {
          //if (i == progressList.length) return const SizedBox(height: 70);
          return BlocProvider.value(
            value: cubit,
            child: phone
              ? ProgressTileMobile(progress: state.progressList[i], isPhone: phone)
              : ProgressTileDesktop(progress: state.progressList[i], isPhone: phone),
          );
        });
  }
}

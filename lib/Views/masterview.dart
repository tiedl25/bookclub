import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/dialogs/updateDialog.dart';
import 'package:bookclub/resources/colors.dart';
import 'package:bookclub/database.dart';
import 'package:bookclub/dialogs/statisticsDialog.dart';
import 'package:bookclub/dialogs/commentDialog.dart';
import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/comment.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/models/progress.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Member> members;
  late List<Book> books;
  late List<Comment> comments;
  late List<Progress> progressList;
  late Book book;
  bool initItems = false;
  late double aspRat;
  late double nameMaxLength;
  int selectedMember = 1;
  List<String> finishSentences = [];

  Future<void> init() async {
    members = await DatabaseHelper.instance.getMemberList();
    books = await DatabaseHelper.instance.getBookList();
    book = await DatabaseHelper.instance.getCurrentBook();
    aspRat = MediaQuery.of(context).size.aspectRatio;
    nameMaxLength = members.map((e) => e.name.length).toList().reduce(max)*10;
    finishSentences = await DatabaseHelper.instance.getFinishSentences();
  }

  int daysLeft(){
    return book.to.difference(DateTime.now()).inDays+1;
  }

  int minimumPages(){
    return (book.pages/book.from.difference(book.to).inDays*book.from.difference(DateTime.now()).inDays).toInt();
  }

  Future<List<Progress>> getProgress() async {
    if (!initItems){
      await init();
      initItems = true;
    } 
    comments = await DatabaseHelper.instance.getComments(book.id!);
    List<Progress> progress = await DatabaseHelper.instance.getProgressList(book.id!);
    return progress;
  }

  String randomFinishSentence(){
    return finishSentences[Random().nextInt(finishSentences.length)];
  }

  @override
  Widget build(BuildContext context) {
    aspRat = MediaQuery.of(context).size.aspectRatio;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: aspRat < 1 ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3,),
          FloatingActionButton(
            mini: true,
            //alignment: Alignment.bottomCenter,
            onPressed: (){
              showCommentDialog();
            },
            child: const Icon(Icons.comment)
          ),
          const Spacer(flex: 1,),
          FloatingActionButton(
            mini: true,
            //alignment: Alignment.bottomCenter,
            onPressed: (){
              showStatisticsDialog();
            },
            child: const Icon(Icons.bar_chart)
          ),
          const Spacer(flex: 3,)
        ]) : null,
      body: Center(
        child: FutureBuilder(
          future: getProgress(),
          builder: (BuildContext context, AsyncSnapshot<List<Progress>> snapshot) {
            if (!snapshot.hasData){
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
                  children: [
                    const Spacer(flex: 1),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 30, 
                          child: Column(
                            children: [
                              bookCarousel(),
                              //const Spacer(flex: 1),
                              AutoSizeText('${book.name} von ${book.author} - ${book.pages} Seiten', textAlign: TextAlign.center, minFontSize: 18,),
                              if (daysLeft() > 0) AutoSizeText('Du hast noch ${daysLeft()} Tag${daysLeft() > 1 ? 'e' : ''} um das Buch zu lesen. Die Zeit rennt!!!', textAlign: TextAlign.center, minFontSize: 18,),
                              if (daysLeft() > 0) AutoSizeText('Seite ${minimumPages()} sollte jetzt schon drin sein.', textAlign: TextAlign.center, minFontSize: 18,),
                            ]
                          )
                        ),
                        if (aspRat > 1) Expanded(flex: 5, child: StatisticsDialog(device: Device.desktop, members: members, books: books)), const Spacer(flex: 1,)
                      ]
                    ),
                    
                    const Divider(),
                    Expanded(flex: 20, child: 
                      Row(
                        children: [
                          Expanded(flex: 20, child: memberBoard(snapshot)),
                          if (aspRat > 1) Expanded(flex: 10, child: CommentDialog(device: Device.desktop, comments: comments, members: members, book: book, nameMaxLength: nameMaxLength,)),
                        ]
                      ),
                    ),
                  ]
            );
          },
        )    
      )
    );
  }

  //Dialogs

  Future<dynamic> showUpdateDialog(Progress progress){
    return showDialog(context: context, builder: (builder){
      return UpdateDialog(book: book, progress: progress, updateProgress: (newProgress) => setState(() {
        progress = newProgress;
      }));
    });
  }

  void showStatisticsDialog(){
    showDialog(context: context, builder: (builder){
      return StatisticsDialog(device: Device.phone, members: members, books: books);
    });
  }

  void showCommentDialog(){
    showDialog(context: context, builder: (builder){
      return CommentDialog(device: Device.phone, members: members, book: book, comments: comments, nameMaxLength: nameMaxLength,);
    });
  }

  void showFinishDialog() {
    showDialog(context: context, builder: (builder){
      return CustomDialog(
        title: const Text(CustomStrings.finishDialogTitle),
        content: Text(randomFinishSentence()),
      );
    });
  }

  //Widgets

  Widget bookCarousel(){
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height/(aspRat<1 ? 3 : 2),
        viewportFraction: aspRat < 1 ? 0.25/aspRat : 0.4/aspRat,
        initialPage: book.id!-1,
        enableInfiniteScroll: false,
        reverse: false,
        autoPlay: false,
        enlargeCenterPage: true,
        enlargeFactor: 0.25,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index, reason) => setState(() => book = books[index]),
      ),
      items: books.map((i) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(i.image_path),
        );
      }).toList(),
    );
  }

  Widget memberBoard(AsyncSnapshot<List<Progress>> snapshot){
    return SizedBox(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(parent:AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 10, right: 10),
        itemCount: snapshot.data!.length+1,
        itemBuilder: (context, i) {
          if (i == snapshot.data!.length) return const SizedBox(height: 70);
          progressList = snapshot.data!;
          return aspRat < 1 ? mobileProgress(progressList[i]) : desktopProgress(progressList[i]);
        }
      ),
    );
  }

  Widget mobileProgress(Progress progress){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: nameMaxLength,
              child: Text(members.firstWhere((element) => element.id == progress.memberId).name)
            ),
            IconButton(
              onPressed: (){
                showUpdateDialog(progress).then((value) {
                  if (value) showFinishDialog();
                });
              }, 
              icon: const Icon(Icons.update),
            ),
            Expanded(child: rating(progress)),
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width*0.9,
          child: progressIndicator(progress),
        )
      ]
    );
  }

  Widget desktopProgress(Progress progress){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: nameMaxLength,
          child: Text(members.firstWhere((element) => element.id == progress.memberId).name)
        ),
        IconButton(
          onPressed: (){
            showUpdateDialog(progress).then((value) {
              if (value) showFinishDialog();
            });
          }, 
          icon: const Icon(Icons.update),
        ),
        const Spacer(flex: 1,),
        Expanded(
          flex: 30,
          child: progressIndicator(progress),
        ),
        const Spacer(flex: 1,),
        rating(progress),
      ],
    );
  }

  Widget progressIndicator(Progress progress){
    return Stack(
      children: [
        LinearProgressIndicator(
          minHeight: 20,
          value: progress.page/(progress.maxPages ?? book.pages),
          borderRadius: BorderRadius.circular(10),
          color: Color(members.firstWhere((element) => element.id == progress.memberId).color),
        ),
        Align(
          alignment: AlignmentGeometry.lerp(Alignment.bottomLeft, Alignment.bottomRight, progress.page/(progress.maxPages ?? book.pages)) as AlignmentGeometry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(progress.page == (progress.maxPages ?? book.pages) ? 'Finished' : 'Seite ${progress.page} (${(progress.page/(progress.maxPages ?? book.pages)*100).toStringAsFixed(0)}%)')
          ),
        )
      ]
    );
  }

  Widget rating(Progress progress) {
    return Row(
      children: List.generate(
        7, 
        (index) {
          return InkWell(
            child: Icon(Icons.book, color: progress.rating == null || progress.rating! < index + 1 ? SpecialColors.bookDefaultColor : SpecialColors.bookSelectedColor),
            onTap: () {
              if (progress.rating == index+1){
                progress.rating = 0;
              } else {
                progress.rating = index + 1;
              }
              setState(() {
                DatabaseHelper.instance.updateProgress(progress);
              });
            },
          );
        }
      )
    );
  }
}
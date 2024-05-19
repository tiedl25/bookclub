import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bookclub/colors.dart';
import 'package:bookclub/database.dart';
import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/comment.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/models/progress.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  late Book book;
  bool initItems = false;
  late double aspRat;
  late double nameMaxLength;
  int selectedMember = 1;

  Future<void> init() async {
    members = await DatabaseHelper.instance.getMemberList();
    books = await DatabaseHelper.instance.getBookList();
    book = await DatabaseHelper.instance.getCurrentBook();
    aspRat = MediaQuery.of(context).size.aspectRatio;
    nameMaxLength = members.map((e) => e.name.length).toList().reduce(max)*10;
  }

  int daysLeft(){
    return book.to.difference(DateTime.now()).inDays;
  }

  int minimumPages(){
    return (book.pages/book.from.difference(book.to).inDays*book.from.difference(DateTime.now()).inDays).toInt();
  }

  Future<void> updatePage(Progress progress) async {
    DatabaseHelper.instance.updateProgress(progress);
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

  void addComment(String value, [void Function(VoidCallback fn)? setState]){
    if(value == ''){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a comment.')));
      return;
    }
    this.setState(() {
      DatabaseHelper.instance.addComment(Comment(text: value, bookId: book.id!, memberId: selectedMember));
    });
    
    if (setState != null) setState(() {comments.add(Comment(text: value, bookId: book.id!, memberId: selectedMember));});
  }

  int getBookPages(){
    return book.pages;
  }

  @override
  Widget build(BuildContext context) {
    aspRat = MediaQuery.of(context).size.aspectRatio;
    return Scaffold(
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
                bookCarousel(),
                const Spacer(flex: 1),
                AutoSizeText('${book.name} von ${book.author} - ${book.pages} Seiten', textAlign: TextAlign.center, minFontSize: 18,),
                if (book.to.difference(DateTime.now()).inDays > 0) 
                  AutoSizeText('Du hast noch ${daysLeft()} Tage um das Buch zu lesen. Die Zeit rennt!!!', textAlign: TextAlign.center, minFontSize: 18,),
                if (book.to.difference(DateTime.now()).inDays > 0) 
                  AutoSizeText('Seite ${minimumPages()} sollte jetzt schon drin sein.', textAlign: TextAlign.center, minFontSize: 18,),
                const Divider(),
                Expanded(flex: 20, child: 
                  Row(
                    children: [
                      Expanded(flex: 20, child: memberBoard(snapshot)),
                      if (aspRat > 1) Expanded(flex: 10, child: commentBoard()),
                    ]
                  ),
                ),
                if (aspRat < 1) IconButton(
                  onPressed: (){
                    showCommentDialog();
                  },
                  icon: const Icon(Icons.comment)
                )
              ]
            );
          },
        )    
      )
    );
  }

  //Dialogs

  void showUpdateDialog(Progress progress){
    showDialog(context: context, builder: (builder){
      TextEditingController currentPageController = TextEditingController(text: progress.page.toString());
      TextEditingController maxPagesController = TextEditingController(text: (progress.maxPages ?? book.pages).toString());
      return AlertDialog(
        title: const Text("Update page number"),
        content: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                decoration: const InputDecoration(labelText: 'Current page'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                autofocus: true,
                controller: currentPageController,
              ),
            ),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(labelText: 'Max. pages'),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[1-9][0-9]*'))],
                keyboardType: TextInputType.number,
                controller: maxPagesController,
              )
            )
          ]
        ),
        actions: [
          TextButton(
            child: const Text("Update"),
            onPressed: (){
              setState(() {
                int nr = int.parse(currentPageController.text);
                nr = nr < 0 ? 0 : nr;
                progress.page = nr > book.pages ? book.pages : nr;
                int maxNr = int.parse(maxPagesController.text);
                progress.maxPages = maxNr < 1 ? 1 : maxNr;
                updatePage(progress);
              });
              Navigator.of(context).pop();
            }
          )
        ]
      );
    });
  }

  void showCommentDialog(){
    showDialog(context: context, builder: (builder){
      return AlertDialog(
        insetPadding: const EdgeInsets.all(15),
        contentPadding: const EdgeInsets.all(5),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: commentBoard(setState),
            );
          }
        )
      );
    });
  }

  void showDeleteDialog(Comment comment, [void Function(VoidCallback fn)? setState]) {
    showDialog(context: context, builder: (builder){
      return AlertDialog(
        title: const Text("Delete comment"),
        content: const Text("Are you sure you want to delete this comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: (){
              this.setState(() { DatabaseHelper.instance.deleteComment(comment.id!); });
              if (setState != null) setState(() {comments.remove(comment);});
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          )
        ]
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
        itemCount: snapshot.data!.length,
        itemBuilder: (context, i) {
          return aspRat < 1 ? mobileProgress(snapshot.data![i]) : desktopProgress(snapshot.data![i]);
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
                showUpdateDialog(progress);
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
            showUpdateDialog(progress);
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
            child: Text(progress.page == book.pages ? 'Finished' : 'Seite ${progress.page} (${(progress.page/(progress.maxPages ?? book.pages)*100).toStringAsFixed(0)}%)')
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
            child: Icon(Icons.book, color: progress.rating == null || progress.rating! < index + 1 ? bookDefaultColor : bookSelectedColor),
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

  Widget commentBoard([void Function(VoidCallback fn)? setState]){
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            itemCount: comments.length,
            itemBuilder: (BuildContext context, int i) {
              return GestureDetector(
                onLongPress: () {
                  showDeleteDialog(comments[i], setState);
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(members.firstWhere((element) => element.id == comments[i].memberId).color),
                    ),
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(comments[i].text, style: const TextStyle(fontSize: 15)),
                        Text(members.firstWhere((element) => element.id == comments[i].memberId).name, style: const TextStyle(fontSize: 10)),
                      ],
                    )
                  ),
                )
              );
            },
          ),
        ),
        commentField(setState)
      ]
    );
  }

  Widget commentField([void Function(VoidCallback fn)? setState]){
    final commentController = TextEditingController();

    return Container(
      //padding: const EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: aspRat < 1 ? 10 : 10, top: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        //color: Color(members.firstWhere((element) => element.id == selectedMember).color),
      ),
      child: TextField(
        onSubmitted: (value) => addComment(value, setState),
        controller: commentController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color(members.firstWhere((element) => element.id == selectedMember).color),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          labelText: 'Comment',
          suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: () => addComment(commentController.text, setState),),
          prefixIcon: Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(width: 1, color: Colors.black38)
              )
            ),
            child: DropdownMenu(
              initialSelection: selectedMember,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(15)),
                //focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              menuStyle: MenuStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.background),
              ),
              dropdownMenuEntries: List.generate(
                members.length, 
                (index) {
                  return DropdownMenuEntry(
                    label: members[index].name,
                    value: index+1,
                  );
                }
              ),
              onSelected: (value) {
                (setState ?? this.setState)(() {
                  selectedMember = value ?? 1;
                });
              },
            )
          )
        ),
      )
    );
  }
}
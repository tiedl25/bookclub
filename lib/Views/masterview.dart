import 'dart:math';

import 'package:bookclub/database.dart';
import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/models/progress.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Member> members;
  late List<Book> books;
  late Book book;
  bool initItems = false;
  late double aspRat;
  late double nameMaxLength;

  @override
  void initState() {
    super.initState();

  }

  init() async {
    members = await DatabaseHelper.instance.getMemberList();
    books = await DatabaseHelper.instance.getBookList();
    book = await DatabaseHelper.instance.getCurrentBook();
    aspRat = MediaQuery.of(context).size.aspectRatio;
    nameMaxLength = members.map((e) => e.name.length).toList().reduce(max)*10;
  }

  showUpdateDialog(Progress progress){
    showDialog(context: context, builder: (builder){
      TextEditingController controller = TextEditingController(text: progress.page.toString());
      return AlertDialog(
        title: const Text("Update page number"),
        content: TextField(
          keyboardType: TextInputType.number,
          autofocus: true,
          controller: controller,
        ),
        actions: [
          TextButton(
            child: const Text("Update"),
            onPressed: (){
              setState(() {
                int nr = int.parse(controller.text);
                progress.page = nr > book.pages ? book.pages : nr;
                updatePage(progress);
              });
              Navigator.of(context).pop();
            }
          )
        ]
      );
    });
  }

  Widget rating(Progress progress) {
    return Row(
      children: List.generate(
        7, 
        (index) {
          return InkWell(
            child: Icon(Icons.book, color: progress.rating == null || progress.rating! < index + 1 ? Colors.grey : Colors.blue),
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

  oldProgressIndicator(Progress progress){
    return Stack(
      children: [
        LinearProgressIndicator(
          minHeight: 20,
          value: progress.page/book.pages,
          borderRadius: BorderRadius.circular(10),
          color: Color(members.firstWhere((element) => element.id == progress.memberId).color),
        ),
        Align(
          alignment: AlignmentGeometry.lerp(Alignment.bottomLeft, Alignment.bottomRight, progress.page/book.pages) as AlignmentGeometry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(progress.page == book.pages ? 'Finished' : 'Page ${progress.page} (${(progress.page/book.pages*100).toStringAsFixed(0)}%)')
          ),
        )
      ]
    );
  }

  desktopProgressIndicator(Progress progress){
    return LinearPercentIndicator(
        //width: MediaQuery.of(context).size.width*0.7,
        widgetIndicator: Text(progress.page == book.pages ? 'Finished' : 'Page ${progress.page} (${(progress.page/book.pages*100).toStringAsFixed(0)}%)'),
        lineHeight: 10,
      percent: progress.page/book.pages,
      progressColor: Color(members.firstWhere((element) => element.id == progress.memberId).color),
      barRadius: const Radius.circular(10),
    );
  }

  mobileProgressIndicator(Progress progress){
    return CircularPercentIndicator(
        //width: MediaQuery.of(context).size.width*0.7,
        widgetIndicator: Text(progress.page == book.pages ? 'Finished' : 'Page ${progress.page} (${(progress.page/book.pages*100).toStringAsFixed(0)}%)'),
      percent: progress.page/book.pages,
      progressColor: Color(members.firstWhere((element) => element.id == progress.memberId).color),
      radius: 50,
    );
  }

  mobileProgress(Progress progress){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
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
        Container(
          width: MediaQuery.of(context).size.width*0.9,
          child: oldProgressIndicator(progress),
        )
        
        
      ]
    );
  }

  desktopProgress(Progress progress){
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
          child: oldProgressIndicator(progress),
        ),
        const Spacer(flex: 1,),
        rating(progress),
        const Spacer(flex: 1,),
      ],
    );
  }

  Widget memberProgress(AsyncSnapshot<List<Progress>> snapshot){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height/2,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(parent:AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.all(16),
        itemCount: snapshot.data!.length,
        itemBuilder: (context, i) {
          return aspRat < 1 ? mobileProgress(snapshot.data![i]) : desktopProgress(snapshot.data![i]);
        }
      ),
    );
  }
  
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
                Spacer(flex: 1),
                bookCarousel(),
                Spacer(flex: 1),
                Expanded(child: memberProgress(snapshot), flex: 10),
              ]
            );
          },
      )    
    )
    );
  }

  Future<void> updatePage(Progress progress) async {
    DatabaseHelper.instance.updateProgress(progress);
  }

  Future<List<Progress>> getProgress() async {
    if (!initItems){
      await init();
      initItems = true;
    } 
    List<Progress> progress = await DatabaseHelper.instance.getProgressList(book.id!);
    return progress;
  }
}
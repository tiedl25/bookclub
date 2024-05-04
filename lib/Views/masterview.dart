import 'package:bookclub/database.dart';
import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/models/progress.dart';
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
  late Book book;
  bool initItems = false;
  late double aspRat;

  @override
  void initState() {
    super.initState();

  }

  init() async {
    members = await DatabaseHelper.instance.getMemberList();
    books = await DatabaseHelper.instance.getBookList();
    book = await DatabaseHelper.instance.getCurrentBook();
    aspRat = MediaQuery.of(context).size.aspectRatio;
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

  Widget memberProgress(AsyncSnapshot<List<Progress>> snapshot){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height/2,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(parent:AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.all(16),
        itemCount: snapshot.data!.length,
        itemBuilder: (context, i) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(members.firstWhere((element) => element.id == snapshot.data![i].memberId).name),
              Row(
                children: [
                  IconButton(
                    onPressed: (){
                      showUpdateDialog(snapshot.data![i]);
                    }, 
                    icon: const Icon(Icons.update),
                  ),
                  Container(
                    width: aspRat > 1 ? MediaQuery.of(context).size.width*0.9 : MediaQuery.of(context).size.width*0.4,
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: snapshot.data![i].page/book.pages,
                          borderRadius: BorderRadius.circular(5),
                          color: Color(members.firstWhere((element) => element.id == snapshot.data![i].memberId).color),
                        ),
                        Align(
                          alignment: AlignmentGeometry.lerp(Alignment.topLeft, Alignment.topRight, snapshot.data![i].page/book.pages) as AlignmentGeometry,
                          child: Text(snapshot.data![i].page == book.pages ? 'Finished' : 'Page ${snapshot.data![i].page} (${(snapshot.data![i].page/book.pages*100).toStringAsFixed(0)}%)'),
                        )
                      ]
                    )
                  )
                ],
              )
              
            ],
          );
        }
      ),
    );
  }
  
  Widget bookCarousel(){
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height/2,
        viewportFraction: 0.35/aspRat,//aspRat < 1 ? 0.7 : 0.2,
        initialPage: book.id!-1,
        enableInfiniteScroll: false,
        reverse: false,
        autoPlay: false,
        enlargeCenterPage: true,
        enlargeFactor: 0.3,
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
                bookCarousel(),
                memberProgress(snapshot)
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
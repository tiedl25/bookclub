import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bookclub/dialogs/addDialog.dart';
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
import 'package:bookclub/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:palette_generator/palette_generator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.changeTheme});

  final String title;
  final Function changeTheme;

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
  Map<int, Color> bookColors = {};
  bool showDescription = false;
  final carouselSliderController = CarouselSliderController();
  final pinController = TextEditingController();
  bool? login;
  bool? admin;

  _MyHomePageState() {
    DatabaseHelper.instance.checkLogin().then((loginValue) async {
      DatabaseHelper.instance.checkAdmin().then((adminValue) {
        setState(() {
          login = loginValue;
          admin = adminValue;
        });
      });
    }
  );
  }

  int get daysLeft => book.to!.difference(DateTime.now()).inDays+1;
  int get minimumPages => (book.pages!/book.from!.difference(book.to!).inDays*book.from!.difference(DateTime.now()).inDays).toInt();
  String get bookInfo => '${book.name} von ${book.author} - ${book.pages} Seiten';
  String get bookDaysLeft => 'Du hast noch $daysLeft Tag${daysLeft > 1 ? 'e' : ''} um das Buch zu lesen. Die Zeit rennt!!!';
  String get bookMinPages => 'Seite $minimumPages sollte jetzt schon drin sein.';
  String get bookProvider => !defaultBook(book.from)
    ? '${members.firstWhere((m) => m.id == book.providerId).name} hat das Buch ausgesucht'
    : 'Als nächstes muss ${members.firstWhere((m) => m.id == book.providerId).name} ein Buch auswählen';

  bool get phone => aspRat < 1 ? true : false;

  bool defaultBook(DateTime? date) => date == null;
  bool get futureBook => book.from == null || book.from!.isAfter(DateTime.now());

  int getProviderId(Book lastBook){
    final lastProviderId = lastBook.providerId;
    final sortedMembers = members;
    sortedMembers.sort((a, b) => b.birthDate.compareTo(a.birthDate));
    final lastProviderIndex = sortedMembers.indexWhere((element) => element.id == lastProviderId);
    return sortedMembers[lastProviderIndex+1].id!;
  }

  Future<void> init() async {
    members = await DatabaseHelper.instance.getMemberList();
    books = await DatabaseHelper.instance.getBookList();

    if (books.last.from!.isBefore(DateTime.now())) {
      books.add(Book(
        id: -1,
        name: null,
        author: null,
        pages: null,
        image_path: null,
        to: null,
        description: null,
        providerId: getProviderId(books.last),
        from: null,
      ));
    }

    book = (await DatabaseHelper.instance.getCurrentBook()) ?? books.last;
    aspRat = MediaQuery.of(context).size.aspectRatio;
    nameMaxLength = members.map((e) => e.name.length).toList().reduce(max)*10;
    finishSentences = await DatabaseHelper.instance.getFinishSentences();
    
    for (Book b in books) {
      bookColors[b.id!] = await getDominantColor(b.image_path) ?? Colors.white;
    }
  }  

  Future<List<Progress>> getProgress() async {
    if (!initItems){
      await init();
      initItems = true;
    } 
    comments = await DatabaseHelper.instance.getComments(book.id!);
    progressList = await DatabaseHelper.instance.getProgressList(book.id!);
    return progressList;
  }

  String randomFinishSentence(){
    return finishSentences[Random().nextInt(finishSentences.length)];
  }

  Future<Color?> getDominantColor(String? imagePath) async {
    if (imagePath == null) {
      return Colors.white;
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

  Future<Color> getImageColor(String imageFile) async {
    final response = await http.get(Uri.parse(imageFile));

    if (response.statusCode != 200) {
      return Colors.black;
    }

    final image = img.decodeImage(response.bodyBytes);

    if (image == null) {
      return Colors.black;
    }
    double red = 0;
    double green = 0;
    double blue = 0;
    double count = 0;
    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        img.Pixel pixel = image.getPixel(x, y);
        red = red + pixel.r;
        green = green + pixel.g;
        blue = blue + pixel.b;
        count = count + 1;
      }
    }
    int rf = red ~/ count;
    int gf = green ~/ count;
    int bf = blue ~/ count;
    return Color.fromRGBO(rf, gf, bf, 1);
  }

  Widget content(){
    return Center(
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
                        const SizedBox(height: 10,),
                        //const Spacer(flex: 1),
                        if (!defaultBook(book.from)) AutoSizeText(bookInfo, textAlign: TextAlign.center, minFontSize: 18,),
                        if (!futureBook) if (daysLeft > 0) AutoSizeText(bookDaysLeft, textAlign: TextAlign.center, minFontSize: 18,),
                        if (!futureBook) if (daysLeft > 0) AutoSizeText(bookMinPages, textAlign: TextAlign.center, minFontSize: 18,),
                        AutoSizeText(bookProvider, textAlign: TextAlign.center, minFontSize: 16,),
                        if (futureBook && members.every((e) => e.veto)) const AutoSizeText(CustomStrings.veto, textAlign: TextAlign.center, minFontSize: 14,),
                        if (futureBook && !members.every((e) => e.veto)) const AutoSizeText(CustomStrings.vetoInfo, textAlign: TextAlign.center, minFontSize: 14,),
                      ]
                    )
                  ),
                  if (aspRat > 1) Expanded(flex: 5, child: StatisticsDialog(device: Device.desktop, members: members, books: books)), const Spacer(flex: 1,)
                ]
              ),
              const Divider(),
              Expanded(
                flex: 20, 
                child: Row(
                  children: [
                    if (futureBook && aspRat > 1) const Spacer(flex: 40,),
                    Expanded(flex: 20, child: !futureBook ? memberBoard(progressList) : votingBoard()),
                    if (futureBook && aspRat > 1) const Spacer(flex: 40,),
                    if (!futureBook && aspRat > 1) Expanded(flex: 10, child: CommentDialog(device: Device.desktop, comments: comments, members: members, book: book, nameMaxLength: nameMaxLength,)),
                  ]
                ),
              ),
            ]
          );
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    aspRat = MediaQuery.of(context).size.aspectRatio;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: phone ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3,),
          FloatingActionButton(
            mini: true,
            //alignment: Alignment.bottomCenter,
            onPressed: (){
              if (!futureBook) {
                showCommentDialog();
              }
              else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(CustomStrings.commentsNotAvailable)));
              }
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
      body: Stack(
        children: [
          content(),
          Positioned(
            right: 0,
            top: 0,
            child: Row(
              children: [
                if (login != null) IconButton(
                  padding: const EdgeInsets.all(10),
                  icon: login! ? const Icon(Icons.login) : const Icon(Icons.logout),
                  onPressed: (){
                    if (login!) {
                      Supabase.instance.client.auth.signOut().then((_) => setState(() => (login = false, admin=false)));
                    } else {
                      showLoginDialog(setState, context).then((loginValue) => DatabaseHelper.instance.checkAdmin().then((adminValue) {
                        setState(() {
                            login = loginValue;
                            admin = adminValue;
                          });
                        })
                      );
                    }
                  },
                ),
                IconButton(
                  padding: const EdgeInsets.all(10),
                  icon: Theme.of(context).brightness == Brightness.dark ? const Icon(Icons.light_mode) : const Icon(Icons.dark_mode),
                  onPressed: (){
                    widget.changeTheme((Theme.of(context).brightness == Brightness.dark) ? ThemeMode.light : ThemeMode.dark);
                  },
                ),
              ],
            )
          )
        ]
      )
    );
  }

  //Dialogs

  void showAddDialog(){
    showDialog(context: context, builder: (builder){
      return AddDialog(lastBook: books[books.length - 2], members: members, updateBooks: () => setState(() {initItems=false;}));
    });
  }

  Future<bool> showUpdateDialog(Progress progress) async {
    login = await DatabaseHelper.instance.checkLogin();
    if (!login!){
      return Future.value(false);
    } 
    admin = await DatabaseHelper.instance.checkAdmin();
    return await showDialog(context: context, builder: (builder){
      return UpdateDialog(book: book, progress: progress, updateProgress: (newProgress) => setState(() {
        progress = newProgress;
      }));
    }) as bool;
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

  void showDescriptionDialog(Color c, Book i){
    showDialog(context: context, builder: (builder){
      return CustomDialog(
        backgroundColor: bookColors[book.id],
        content: description(c, i)
      );
    });
  }

  Widget description(Color c, Book i) => SingleChildScrollView(
    child: SelectableText(
      book.description ?? '', 
      onTap: () => setState(() {
        if(i.id == book.id){
          phone ? null : showDescription = !showDescription;
        }
        else {
          showDescription = false;
          carouselSliderController.animateToPage(i.id!-1);
        }
      }), 
      style: TextStyle(color: Color(c.value).computeLuminance() > 0.2 ? Colors.black : Colors.white)
    )
  );

  Widget bookPlaceholder(){
    return admin! && book == books.last
    ? Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/book_placeholder.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: GestureDetector(
          onTap: () => showAddDialog(),
          child: const Center(
            child: Icon(Icons.add, color: Colors.black, size: 100),
          ),
        )
      )
    : Image.asset('assets/images/book_placeholder.jpeg');
  }

  //Widgets

  Widget bookCarousel(){
    return CarouselSlider(
      carouselController: carouselSliderController,
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height/(aspRat<1 ? 3 : 2),
        viewportFraction: phone ? 0.25/aspRat : 0.4/aspRat,
        initialPage: books.indexWhere((b) => b.id == book.id),
        enableInfiniteScroll: false,
        reverse: false,
        autoPlay: false,
        enlargeCenterPage: true,
        enlargeFactor: 0.25,
        scrollDirection: Axis.horizontal,
        onPageChanged: (index, reason) => setState(() {
          book = books[index];
          showDescription = false;
        }),
      ),
      items: books.map((i) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onTap: () => setState(() {
              if(i.id == book.id){
                if (!defaultBook(i.from)) phone ? showDescriptionDialog(bookColors[i.id]!, i) : showDescription = !showDescription;
              }
              else {
                showDescription = false;
                carouselSliderController.animateToPage(i.id!-1);
              }
            }),
            child: !defaultBook(i.from) && showDescription && i.id == book.id 
              ? Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: bookColors[i.id]),
                  child: description(bookColors[i.id]!, i)
                ) 
              : Stack(
                children: [
                  !defaultBook(i.from)
                    ? Image.network(i.image_path!)
                    : bookPlaceholder(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: CircleAvatar(
                        radius: phone ? 20 : 30,
                        backgroundImage: members.firstWhere((m) => m.id == i.providerId).profilePicture != null
                          ? MemoryImage(members.firstWhere((m) => m.id == i.providerId).profilePicture!) as ImageProvider<Object>
                          : const AssetImage('assets/images/pp_placeholder.jpeg'),
                      ),
                    )
                  )
                ]
              ),
          ),
        );
      }).toList(),
    );
  }

  Widget votingBoard(){
    return GridView.builder(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: phone ? 70 : 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        crossAxisCount: 2, 
        childAspectRatio: 5/2
      ),
      itemCount: members.length,
      itemBuilder: (context, i) => TextButton(
        style: TextButton.styleFrom(
          backgroundColor: members[i].veto ? Color(members[i].color) : Theme.of(context).colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
        ),
          onPressed: () async {
            login = await showLoginDialog(setState, context, CustomStrings.loginDialogTitle);
            if (!login!) return;
            admin = await DatabaseHelper.instance.checkAdmin();
            setState(() {
              members[i].veto = !members[i].veto;
              DatabaseHelper.instance.updateMember(members[i]);
            });
          }, 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 10,
                backgroundImage: members[i].profilePicture != null
                  ? MemoryImage(members[i].profilePicture!) as ImageProvider<Object>
                  : const AssetImage('assets/images/pp_placeholder.jpeg'),
              ),
              const SizedBox(width: 10),
              Text(members[i].name, style: TextStyle(color: members[i].veto ? Colors.black : Theme.of(context).textTheme.bodySmall?.color),),
            ],
          )
        ),
    );
  }

  Widget memberBoard(List<Progress> progressList){
    return ListView.builder(
      physics: const BouncingScrollPhysics(parent:AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: phone ? 70 : 10),
      itemCount: progressList.length,
      itemBuilder: (context, i) {
        //if (i == progressList.length) return const SizedBox(height: 70);
        return phone ? mobileProgress(progressList[i]) : desktopProgress(progressList[i]);
      }
    );
  }

  List<Widget> progressDescription(Progress progress){
    return [
      CircleAvatar(
        radius: 10,
        backgroundImage: members.firstWhere((element) => element.id == progress.memberId).profilePicture != null
          ? MemoryImage(members.firstWhere((element) => element.id == progress.memberId).profilePicture!) as ImageProvider<Object>
          : const AssetImage('assets/images/pp_placeholder.jpeg'),
      ),
      const SizedBox(width: 10,),
      SizedBox(
        width: nameMaxLength,
        child: Text(members.firstWhere((element) => element.id == progress.memberId).name)
      ),
      IconButton(
        onPressed: () async {
          login = await showLoginDialog(setState, context, CustomStrings.loginDialogTitle);
          if (!login!) return;
          admin = await DatabaseHelper.instance.checkAdmin();
          showUpdateDialog(progress).then((value) {
            if (value) showFinishDialog();
          });
        }, 
        icon: const Icon(Icons.update),
      ),
    ];
  }


  Widget mobileProgress(Progress progress){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...progressDescription(progress),
            Expanded(child: rating(progress)),
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width*0.9,
          child: !futureBook ? progressIndicator(progress) : Container(),
        )
      ]
    );
  }

  Widget desktopProgress(Progress progress){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ...progressDescription(progress),
        const Spacer(flex: 1,),
        Expanded(
          flex: 30,
          child: !futureBook ? progressIndicator(progress) : Container(),
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
          value: progress.page/(progress.maxPages ?? book.pages!),
          borderRadius: BorderRadius.circular(10),
          color: Color(members.firstWhere((element) => element.id == progress.memberId).color),
        ),
        Align(
          alignment: AlignmentGeometry.lerp(Alignment.bottomLeft, Alignment.bottomRight, progress.page/(progress.maxPages ?? book.pages!)) as AlignmentGeometry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(progress.page == (progress.maxPages ?? book.pages) ? 'Finished' : 'Seite ${progress.page} (${(progress.page/(progress.maxPages ?? book.pages!)*100).toStringAsFixed(0)}%)')
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
            onTap: () async {
              login = await showLoginDialog(setState, context, CustomStrings.loginDialogTitle);
              if (!login!) return;
              admin = await DatabaseHelper.instance.checkAdmin();
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
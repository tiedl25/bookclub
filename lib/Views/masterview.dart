import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> members = ['Tiedl', 'Ronja', 'Bärtschi', 'Johanna', 'Leo', 'Eve'];
  late List<int> pages;
  int bookPages = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height/2,
              child: Image.asset('assets/images/the picture.jpg'),
            ),
            FutureBuilder(
              future: getMembers(),
              builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
                if (!snapshot.hasData){
                  return const Center(child: CircularProgressIndicator());
                }

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
                        Text(members[i].toString()),
                        IconButton(
                          onPressed: (){
                            showDialog(context: context, builder: (builder){
                              TextEditingController controller = TextEditingController(text: snapshot.data![i].toString());
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
                                        updatePage(members[i], nr > bookPages ? bookPages : nr);
                                      });
                                      Navigator.of(context).pop();
                                    }
                                  )
                                ]
                              );
                            });
                          }, 
                          icon: const Icon(Icons.update),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          margin: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              LinearProgressIndicator(
                                value: snapshot.data![i]/bookPages,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              Align(
                                alignment: AlignmentGeometry.lerp(Alignment.topLeft, Alignment.topRight, snapshot.data![i]/bookPages) as AlignmentGeometry,
                                child: Text(snapshot.data![i] == bookPages ? 'Finished' : 'Page ${snapshot.data![i]}'),
                              )
                            ]
                          )
                        )
                      ],
                    );
                  }
                ),
                );
              },
            )
          ],
        )
        
        
        
        

    )
    );
  }

  Future<void> updatePage(String name, int page) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(name, page);
  }

  Future<List<int>> getMembers() async {
    final prefs = await SharedPreferences.getInstance();
    pages = [];
    for(String name in members){
      pages.add(prefs.getInt(name) ?? 0);
    }

    bookPages = prefs.getInt('pages') ?? 0;
    return pages;
  }
}
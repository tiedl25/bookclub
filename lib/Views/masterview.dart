import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';

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

                return Container(
                  //width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height/2,
                  child: ListView.builder(
                  physics: const BouncingScrollPhysics(parent:AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    return Row(
                      children: [
                        ListTile(
                          title: Text(members[i]),
                        ),
                        Container(
                          alignment: Alignment.topCenter,
                          margin: EdgeInsets.all(20),
                          child: LinearProgressIndicator(
                            value: 0.7,
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

  Future<List<int>> getMembers() async {
    final prefs = await SharedPreferences.getInstance();
    pages = [];
    for(String name in members){
      pages.add(prefs.getInt(name) ?? 0);
    }
    return pages;
  }
}
import 'package:bookclub/resources/colors.dart';
import 'package:bookclub/database.dart';
import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/models/progress.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:flutter/material.dart' hide Dialog;

enum Device {
  phone,
  desktop,
}

class StatisticsDialog extends StatefulWidget {
  const StatisticsDialog({super.key, required this.device, required this.members, required this.books});
  final List<Member> members;
  final List<Book> books;

  final Device device;

  @override
  State<StatisticsDialog> createState() => _StatisticsDialogState();
}

class _StatisticsDialogState extends State<StatisticsDialog> {
  late Future<List<Progress>> progressFuture;
  late List<Progress> progress;

  @override
  void initState() {
    super.initState();
    progressFuture = DatabaseHelper.instance.getProgressList();
  }

  Map<String, double> nominateShamePerson() {
    Map<String, double> progressByMember = {};
    for (var member in widget.members){
      var memberProgress = progress.where((element) => element.memberId == member.id);
      if (memberProgress.isNotEmpty){
        final test = memberProgress.reduce((element, value) => Progress(page: element.page + value.page, maxPages: (element.maxPages ?? widget.books[element.bookId!-1].pages) + (value.maxPages ?? widget.books[value.bookId!-1].pages)));
        progressByMember[member.name] = test.page / test.maxPages!;
      }
    }
    return Map.fromEntries(progressByMember.entries.toList()..sort((e1, e2) => e1.value.compareTo(e2.value)));
  }

  Widget wallOfShame() {
    final progressByMember = nominateShamePerson().entries.toList();

    final icons = [
      const Icon(Icons.star, color: SpecialColors.gold, size: 40),
      Container(padding: const EdgeInsets.symmetric(horizontal: 5), child: const Icon(Icons.star, color: SpecialColors.silver, size: 30)),
      Container(padding: const EdgeInsets.symmetric(horizontal: 7.5), child: const Icon(Icons.star, color: SpecialColors.bronze, size: 25)),
    ];
    
    return Column(
      children: [
        const Text(Strings.statisticsTitle, style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          itemCount: progressByMember.length,
          itemBuilder: (context, index) {
            final e = progressByMember[index];

            return Row(
              mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                if (index < 3) icons[index]
                else Container(padding: const EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.book, color: SpecialColors.bookSelectedColor, size: 20)),
                const SizedBox(width: 5),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(color: Colors.black, fontSize: 16)),
                      Text("${(e.value*100).toStringAsFixed(0)} %", style: const TextStyle(color: Colors.black, fontSize: 16))
                    ]
                  )
                )
              ]
            );
          },          
        )
      ],
    );
  }

  Widget phone(){
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            wallOfShame(),
          ]
        )
      ),
    );
  }

  Widget desktop(){
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          wallOfShame(),
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: progressFuture, 
      builder: (BuildContext context, AsyncSnapshot<List<Progress>> snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.isNotEmpty) progress = snapshot.data!;

        return widget.device == Device.phone ? phone() : desktop();
      }
      
    );
  }
}
import 'dart:math' as math;

import 'package:bookclub/bloc/statisticsDialog_bloc.dart';
import 'package:bookclub/bloc/statisticsDialog_states.dart';
import 'package:bookclub/resources/colors.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:bookclub/widgets/ratingBarChart.dart';
import 'package:fl_heatmap/fl_heatmap.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter_bloc/flutter_bloc.dart';

mixin StatisticsMixin on StatelessWidget {
  late BuildContext context;
  late StatisticsDialogCubit cubit;

  final icons = [
  const Icon(Icons.star, color: SpecialColors.gold, size: 40),
    Container(padding: const EdgeInsets.symmetric(horizontal: 5), child: const Icon(Icons.star, color: SpecialColors.silver, size: 30)),
    Container(padding: const EdgeInsets.symmetric(horizontal: 7.5), child: const Icon(Icons.star, color: SpecialColors.bronze, size: 25)),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Icon(Icons.book, color: SpecialColors.bookSelectedColor, size: 20))
  ];

  Widget wallOfShame(List<Member> members){
    final progressByMember = cubit.nominateShamePerson().entries.toList();

    int iconIndex=0;
    final memberIcons = [];

    for (var i = 0; i < progressByMember.length; i++){
      if (i == 0) memberIcons.add(icons[0]);
      else if (progressByMember[i].value == progressByMember[i-1].value || iconIndex > 2){
        memberIcons.add(icons[iconIndex]);
      } else {
        memberIcons.add(icons[iconIndex+1]);
        if (iconIndex<3) iconIndex++;
      }
    }
    
    return Column(
      children: [
        const Text(CustomStrings.statisticsTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: progressByMember.length,
          itemBuilder: (context, index) {
            final e = progressByMember[index];

            final member = members.firstWhere((element) => element.name == e.key);

            return Row(
              mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                memberIcons[index],
                const SizedBox(width: 5),
                CircleAvatar(
                  radius: 10,
                  backgroundImage: member.profilePicture != null
                    ? MemoryImage(member.profilePicture!) as ImageProvider<Object>
                    : const AssetImage('assets/images/pp_placeholder.jpeg'),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(fontSize: 16)),
                      Text("${(e.value*100).toStringAsFixed(0)} %", style: const TextStyle(fontSize: 16))
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

  Widget bestRankedBook() {
    dynamic ratingByBook = cubit.bookRatingList().entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value));
    ratingByBook = ratingByBook.sublist(0,3);

    int iconIndex=0;
    final bookIcons = [];

    for (var i = 0; i < ratingByBook.length; i++){
      if (i == 0) bookIcons.add(icons[0]);
      else if (ratingByBook[i].value == ratingByBook[i-1].value || iconIndex > 2){
        bookIcons.add(icons[iconIndex]);
      } else {
        bookIcons.add(icons[iconIndex+1]);
        if (iconIndex<3) iconIndex++;
      }
    }

    return Column(
      children: [
        const Text(CustomStrings.statisticsTitle2, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: ratingByBook.length,
          itemBuilder: (context, index) {
            final e = ratingByBook[index];

            return Row(
              mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                bookIcons[index],
                const SizedBox(width: 5),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(flex: 10, child: Text(e.key.name!, style: const TextStyle(fontSize: 16))),
                      const Spacer(),
                      Text("${(e.value).toStringAsFixed(2)} ", style: const TextStyle(fontSize: 16)),
                    ]
                  )
                ),
                Icon(Icons.book, color: SpecialColors.bookSelectedColor, size: 16)
              ]
            );
          },          
        )
      ]
    );
  }

  Widget averageMemberRating(){
    final ratingByMember = cubit.memberRatingList().entries.toList();

    return SizedBox(
      height: 200,
      child: RatingBarChart(title: CustomStrings.statisticsTitle5, angle: -math.pi / 3, spacing: 16, reservedSpace:  50, xAxisList: ratingByMember.map((e) => e.key).toList(), yAxisList: ratingByMember.map((e) => e.value).toList(), interval: 1));
  }

  Widget averageBookRating(){
    final ratingByBook = cubit.bookRatingList().entries.toList();

    return SizedBox(
      height: 250,
      child: RatingBarChart(title: CustomStrings.statisticsTitle6, angle: -math.pi / 2.5, spacing: 30, reservedSpace:  70, xAxisList: ratingByBook.map((e) => e.key).toList(), yAxisList: ratingByBook.map((e) => e.value).toList(), interval: 1));
  }

  Widget greatestTasteMatch(HeatmapItem? selectedItem) {
    final tasteMatchByMember = cubit.tasteMatch().entries.toList();

    List<String> memberNames = tasteMatchByMember.map((e) => e.key.name).toList();

    final heatmapData = HeatmapData(
      rows: memberNames,
      columns: memberNames,
      items: [
        for (var row = 0; row < tasteMatchByMember.length; row++)
          for (var col = 0; col < tasteMatchByMember.length; col++)
            HeatmapItem(
              value: (tasteMatchByMember[row].value[col][1]*100).toInt(),
              xAxisLabel: memberNames[col],
              yAxisLabel: memberNames[row],
            )
      ]
    );

    return Column(
      children: [
        const Text(CustomStrings.statisticsTitle3, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Heatmap(
          heatmapData: heatmapData,
          onItemSelectedListener: (HeatmapItem? selectedItem) => cubit.changeSelectedItem(selectedItem),
        ),
        if (selectedItem != null) Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(selectedItem.yAxisLabel!, style: const TextStyle(fontSize: 16)),
            Icon(selectedItem.value > 50 ? Icons.favorite : Icons.heart_broken, color: Colors.red),
            Text ("${selectedItem.value} %", style: const TextStyle(fontSize: 16)),
            Icon(selectedItem.value > 50 ? Icons.favorite : Icons.heart_broken, color: Colors.red),
            Text(selectedItem.xAxisLabel!, style: const TextStyle(fontSize: 16))
          ]
        )
      ],
    );
  }
}

class StatisticsDialog extends StatelessWidget with StatisticsMixin {
  @override
  Widget build(BuildContext context) {
    context = context;
    cubit = context.read<StatisticsDialogCubit>();

    return BlocBuilder<StatisticsDialogCubit, StatisticsDialogState>(
      buildWhen: (_, current) => current is StatisticsDialogLoaded || current is StatisticsDialogLoading,
      builder: (context, state) => state is StatisticsDialogLoaded
        ? CustomDialog(
            padding: 5,
            fullWindow: true,
            content: Container(
              padding: const EdgeInsets.all(10),
              child: Container(
                constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height-60,
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      wallOfShame(state.members),
                      const SizedBox(height: 30),
                      bestRankedBook(),
                      const SizedBox(height: 30),
                      averageMemberRating(),
                      const SizedBox(height: 30),
                      averageBookRating(),
                      const SizedBox(height: 30),
                      greatestTasteMatch(state.selectedItem),
                    ]
                  ),
                ),
              )
            ),
          )
        : const Center(child: CircularProgressIndicator()),
      
    );
  }
}

class StatisticsTile extends StatelessWidget with StatisticsMixin {
  @override
  Widget build(BuildContext context) {
    context = context;
    cubit = context.read<StatisticsDialogCubit>();

    return BlocBuilder<StatisticsDialogCubit, StatisticsDialogState>(
      buildWhen: (_, current) => current is StatisticsDialogLoaded || current is StatisticsDialogLoading,
      builder: (context, state) => state is StatisticsDialogLoaded
        ? Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                wallOfShame(state.members),
                const SizedBox(height: 50),
                bestRankedBook(),
                const SizedBox(height: 50),
                averageMemberRating(),
                const SizedBox(height: 50),
                averageBookRating(),
                const SizedBox(height: 50),
                greatestTasteMatch(state.selectedItem),
              ]
            )
          )
        : const Center(child: CircularProgressIndicator()),
      
    );
  }
}
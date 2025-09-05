import 'package:bookclub/bloc/masterview_bloc.dart';
import 'package:bookclub/bloc/masterview_states.dart';
import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/models/progress.dart';
import 'package:bookclub/resources/colors.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:bookclub/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin ProgressTileMixin on StatelessWidget {
  late BuildContext context;
  late MasterViewCubit cubit;
  late Book book;

  bool get futureBook =>
      book.from == null || book.from!.isAfter(DateTime.now());

  Widget progressIndicator(Progress progress, List<Member> members) {
    return Stack(children: [
      LinearProgressIndicator(
        minHeight: 20,
        value: progress.page / (progress.maxPages ?? book.pages!),
        borderRadius: BorderRadius.circular(10),
        color: Color(members
            .firstWhere((element) => element.id == progress.memberId)
            .color),
      ),
      Align(
        alignment: AlignmentGeometry.lerp(
                Alignment.bottomLeft,
                Alignment.bottomRight,
                progress.page / (progress.maxPages ?? book.pages!))
            as AlignmentGeometry,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(progress.page == (progress.maxPages ?? book.pages)
                ? 'Finished'
                : 'Seite ${progress.page} (${(progress.page / (progress.maxPages ?? book.pages!) * 100).toStringAsFixed(0)}%)')),
      )
    ]);
  }

  Widget rating(Progress progress) {
    return Row(
        children: List.generate(7, (index) {
      return InkWell(
        child: Icon(Icons.book,
            color: progress.rating == null || progress.rating! < index + 1
                ? SpecialColors.bookDefaultColor
                : SpecialColors.bookSelectedColor),
        onTap: () async {
          final login = await showLoginDialog(
              cubit, context, CustomStrings.loginDialogTitle);
          if (!login!) return;
          cubit.rate(login, progress, index + 1);
        },
      );
    }));
  }

  List<Widget> progressDescription(
      nameMaxLength, Progress progress, List<Member> members) {
    return <Widget>[
      CircleAvatar(
        radius: 10,
        backgroundImage: members
                    .firstWhere((element) => element.id == progress.memberId)
                    .profilePicture !=
                null
            ? MemoryImage(members
                .firstWhere((element) => element.id == progress.memberId)
                .profilePicture!) as ImageProvider<Object>
            : const AssetImage('assets/images/pp_placeholder.jpeg'),
      ),
      const SizedBox(
        width: 10,
      ),
      SizedBox(
          width: nameMaxLength,
          child: Text(members
              .firstWhere((element) => element.id == progress.memberId)
              .name)),
      IconButton(
        onPressed: () async {
          bool? login = await showLoginDialog(
              cubit, context, CustomStrings.loginDialogTitle);
          if (!login!) return;
          cubit.showUpdateDialog(login, progress);
        },
        icon: const Icon(Icons.update),
      ),
    ];
  }
}

class ProgressTileMobile extends StatelessWidget with ProgressTileMixin {
  Progress progress;

  ProgressTileMobile({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    this.context = context;
    cubit = context.read<MasterViewCubit>();

    return BlocBuilder<MasterViewCubit, MasterViewState>(
      buildWhen: (_, current) => current is MasterViewLoaded,
      builder: (context, state) {
        state as MasterViewLoaded;
        book = state.book;

        return Column(children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ...progressDescription(
                      state.nameMaxLength, progress, state.members),
                  Expanded(child: rating(progress)),
                ],
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: !futureBook
                ? progressIndicator(progress, state.members)
                : Container(),
          )
        ]);
      },
    );
  }
}

class ProgressTileDesktop extends StatelessWidget with ProgressTileMixin {
  Progress progress;

  ProgressTileDesktop({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    this.context = context;
    cubit = context.read<MasterViewCubit>();

    return BlocBuilder<MasterViewCubit, MasterViewState>(
      buildWhen: (_, current) => current is MasterViewLoaded,
      builder: (context, state) {
        state as MasterViewLoaded;
        book = state.book;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...progressDescription(
                state.nameMaxLength, progress, state.members),
            const Spacer(
              flex: 1,
            ),
            Expanded(
              flex: 30,
              child: !futureBook
                  ? progressIndicator(progress, state.members)
                  : Container(),
            ),
            const Spacer(
              flex: 1,
            ),
            rating(progress),
          ],
        );
      },
    );
  }
}
import 'package:bookclub/bloc/masterview_bloc.dart';
import 'package:bookclub/bloc/masterview_states.dart';
import 'package:bookclub/bloc/profileDialog_bloc.dart';
import 'package:bookclub/dialogs/profileDialog.dart';
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
  late Member member;

  late bool isPhone;

  bool get futureBook => book.from == null || book.from!.isAfter(DateTime.now());

  void showProfile() {
    showDialog(
      context: context,
      builder: (builder) {
        return BlocProvider(
          create: (context) => ProfileDialogCubit(member: member),
          child: ProfileDialog(isPhone: isPhone),
        );
      });
  }

  Widget progressIndicator(Progress progress) {
    return Stack(children: [
      LinearProgressIndicator(
        minHeight: 20,
        value: progress.page / (progress.maxPages ?? book.pages!),
        borderRadius: BorderRadius.circular(10),
        color: Color(member.color),
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

  List<Widget> progressDescription(nameMaxLength, Progress progress) {
    return <Widget>[
      GestureDetector(
        onTap: () => showProfile(),
        child: Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundImage: member.profilePicture !=
                      null
                  ? MemoryImage(member.profilePicture!) as ImageProvider<Object>
                  : const AssetImage('assets/images/pp_placeholder.jpeg'),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
                width: nameMaxLength,
                child: Text(member.name)),
          ],
        ),
      ),
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
  bool isPhone;

  ProgressTileMobile({super.key, required this.progress, required this.isPhone});

  @override
  Widget build(BuildContext context) {
    this.context = context;
    cubit = context.read<MasterViewCubit>();

    return BlocBuilder<MasterViewCubit, MasterViewState>(
      buildWhen: (_, current) => current is MasterViewLoaded,
      builder: (context, state) {
        state as MasterViewLoaded;
        book = state.book;
        member = state.members.firstWhere((element) => element.id == progress.memberId);

        return Column(children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ...progressDescription(
                      state.nameMaxLength, progress),
                  Expanded(child: rating(progress)),
                ],
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: !futureBook
                ? progressIndicator(progress)
                : Container(),
          )
        ]);
      },
    );
  }
}

class ProgressTileDesktop extends StatelessWidget with ProgressTileMixin {
  Progress progress;
  bool isPhone;

  ProgressTileDesktop({super.key, required this.progress, required this.isPhone});

  @override
  Widget build(BuildContext context) {
    this.context = context;
    cubit = context.read<MasterViewCubit>();

    return BlocBuilder<MasterViewCubit, MasterViewState>(
      buildWhen: (_, current) => current is MasterViewLoaded,
      builder: (context, state) {
        state as MasterViewLoaded;
        book = state.book;
        member = state.members.firstWhere((element) => element.id == progress.memberId);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...progressDescription(
                state.nameMaxLength, progress),
            const Spacer(
              flex: 1,
            ),
            Expanded(
              flex: 30,
              child: !futureBook
                  ? progressIndicator(progress)
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

import 'package:bookclub/bloc/masterview_bloc.dart';
import 'package:bookclub/bloc/masterview_states.dart';
import 'package:bookclub/models/comment.dart';
import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/resources/colors.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:bookclub/utils.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter_bloc/flutter_bloc.dart';

mixin CommentMixin on StatelessWidget {
  late BuildContext context;
  late MasterViewCubit cubit;

  void showDeleteDialog(Comment comment) {
    showDialog(context: context, builder: (builder){
      return CustomDialog(
        title: const Text(CustomStrings.deleteCommentDialogTitle),
        content: const Text(CustomStrings.deleteCommentDialogContent),
        submitButton: TextButton(
          onPressed: () => [
            cubit.deleteComment(comment),
            Navigator.pop(context)
          ],
          child: Text("Delete", style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium!.fontSize)),
        )
      );
    });
  }

  Widget commentField(MasterViewLoaded state) {
    final commentController = TextEditingController();

    return Container(
      //padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          TextField(
            style: const TextStyle(color: SpecialColors.commentTextcolor),
            cursorColor: SpecialColors.commentTextcolor,
            maxLines: 5,
            minLines: 1,
            onSubmitted: (value) async {
              bool? login = await showLoginDialog(cubit, context, CustomStrings.loginDialogTitle);
              if (!login!) return;
              cubit.addComment(login, value);
            },
            controller: commentController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 50, right: 10, top: 10, bottom: 10),
              filled: true,
              fillColor: Color(state.members[state.selectedMember-1].color),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: SpecialColors.commentTextcolor)),
              labelText: state.members[state.selectedMember-1].name,
              labelStyle: const TextStyle(color: SpecialColors.commentTextcolor),
              floatingLabelStyle: const TextStyle(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              commentDropDown(state), 
              IconButton(
                icon: const Icon(Icons.send, color: SpecialColors.commentTextcolor), 
                onPressed: () async {
                  bool? login = await showLoginDialog(cubit, context, CustomStrings.loginDialogTitle);
                  if (!login!) return;
                  cubit.addComment(login, commentController.text);
                }
              ),
            ]
          ),
        ]
      )
    );
  }

  Widget commentDropDown(MasterViewLoaded state) {
    return DropdownMenu(
      trailingIcon: const Icon(Icons.person, color: SpecialColors.commentTextcolor),
      selectedTrailingIcon: const Icon(Icons.person, color: SpecialColors.commentTextcolor),
      width: 50,
      textStyle: const TextStyle(fontSize: 0),
      initialSelection: state.selectedMember,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(15),),
      ),
      menuStyle: MenuStyle(
        fixedSize: WidgetStateProperty.all(Size.fromWidth(state.nameMaxLength)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      ),
      dropdownMenuEntries: List.generate(
        state.members.length,
        (index) {
          return DropdownMenuEntry(
            label: state.members[index].name,
            value: index+1,
          );
        }
      ),
      onSelected: (value) => cubit.selectMember(value),
    );
  }

  Widget comment(MasterViewLoaded state, int i){
    const emptySpace = "                   ‎";
    final commentController = TextEditingController(text: "${state.comments[i].text}$emptySpace");
    final member = state.members.firstWhere((element) => element.id == state.comments[i].memberId);
    final memberName = "${member.name}$emptySpace";

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(state.members.firstWhere((element) => element.id == state.comments[i].memberId).color),
          ),
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    readOnly: !state.comments[i].editMode,
                    maxLines: null,
                    style: const TextStyle(fontSize: 15, color: SpecialColors.commentTextcolor),
                    controller: commentController,
                    decoration: const InputDecoration(isDense: true, border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, disabledBorder: InputBorder.none),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: member.profilePicture != null
                          ? MemoryImage(member.profilePicture!) as ImageProvider<Object>
                          : const AssetImage('assets/images/pp_placeholder.jpeg'),
                      ),
                      const SizedBox(width: 10,),
                      Text(memberName, style: const TextStyle(fontSize: 10, color: SpecialColors.commentTextcolor)),
                    ],
                  ),
                ]
              )
        ),
        Positioned(
          right: 0, 
          bottom: 0, 
          child: Padding(padding: const EdgeInsets.all(10), 
            child: Row(
              children: [
                state.comments[i].editMode
                  ? IconButton(
                      onPressed: () async {
                        bool? login = await showLoginDialog(cubit, context, CustomStrings.loginDialogTitle);
                        if (!login!) return;
                        cubit.updateComment(login, commentController.text, i);
                      },
                      icon: const Icon(Icons.check, color: SpecialColors.commentTextcolor, size: 15)
                    ) 
                  : IconButton(
                      onPressed: () async {
                        bool? login = await showLoginDialog(cubit, context, CustomStrings.loginDialogTitle);
                        if (!login!) return;
                        cubit.updateLogin(login);
                        showDeleteDialog(state.comments[i]);
                      },
                      icon: const Icon(Icons.delete, color: SpecialColors.commentTextcolor, size: 15)
                    ),
                    IconButton(
                      onPressed: () async {
                        bool? login = await showLoginDialog(cubit, context, CustomStrings.loginDialogTitle);
                        if (!login!) return;
                        cubit.toggleEditMode(login, i);
                      },
                      icon: Icon(state.comments[i].editMode ? Icons.close : Icons.edit, color: SpecialColors.commentTextcolor, size: 15)
                    )
              ]
            )
          ),
        ),
      ],
    );
  }

  Widget commentBoard(){
    return BlocBuilder<MasterViewCubit, MasterViewState>(
      builder: (context, state) {
        state as MasterViewLoaded;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(parent:AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.only(top: 10),
                itemCount: state.comments.length,
                itemBuilder: (BuildContext context, int i) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: comment(state, i),
                  );
                },
              ),
            ),
            commentField(state)
          ],
        );
      },
    );
  }
}

class CommentDialog extends StatelessWidget with CommentMixin {
  @override
  Widget build(BuildContext context) {
    this.context = context;
    cubit = context.read<MasterViewCubit>();

    return CustomDialog(
      padding: 5,
      fullWindow: true,
      content: Expanded(child: commentBoard()),
    );
  }
}

class CommentTile extends StatelessWidget with CommentMixin {
  @override
  Widget build(BuildContext context) {
    this.context = context;
    cubit = context.read<MasterViewCubit>();

    return commentBoard();
  }
}
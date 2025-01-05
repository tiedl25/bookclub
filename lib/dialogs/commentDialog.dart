import 'package:bookclub/models/comment.dart';
import 'package:bookclub/database.dart';
import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/resources/colors.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:flutter/material.dart' hide Dialog;

class CommentDialog extends StatefulWidget {
  const CommentDialog({super.key, required this.device, required this.comments, required this.members, required this.book, required this.nameMaxLength});
  final List<Member> members;
  final Book book;
  final List<Comment> comments;
  final double nameMaxLength;

  final Device device;

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  late final List<Member> members;
  late final Book book;
  late List<Comment> comments;
  int selectedMember = 1;
  late final double nameMaxLength;
  late List<bool> editComment;

  @override
  void initState() {
    super.initState();
    members = widget.members;
    book = widget.book;
    comments = widget.comments;
    editComment = List.generate(comments.length, (index) => false);
    nameMaxLength = widget.nameMaxLength;
  }

  void addComment(String value){
    if(value == ''){
      return;
    }
    editComment.add(false);
    DatabaseHelper.instance.addComment(Comment(text: value, bookId: book.id!, memberId: selectedMember)).then((value) => setState(() => comments.add(Comment.fromMap(value[0]))));  
  }

  void showDeleteDialog(Comment comment) {
    showDialog(context: context, builder: (builder){
      return CustomDialog(
        title: const Text(CustomStrings.deleteCommentDialogTitle),
        content: const Text(CustomStrings.deleteCommentDialogContent),
        submitButton: TextButton(
          onPressed: (){
            setState(() {
                DatabaseHelper.instance.deleteComment(comment.id!); 
                editComment.removeAt(comments.indexOf(comment));
                comments.remove(comment);
              }
            );
            Navigator.pop(context);
          },
          child: Text("Delete", style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium!.fontSize)),
        )
      );
    });
  }

  Widget commentField(){
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
            onSubmitted: (value) => addComment(value),
            controller: commentController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 50, right: 10, top: 10, bottom: 10),
              filled: true,
              fillColor: Color(members.firstWhere((element) => element.id == selectedMember).color),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: SpecialColors.commentTextcolor)),
              labelText: members[selectedMember-1].name,
              labelStyle: const TextStyle(color: SpecialColors.commentTextcolor),
              floatingLabelStyle: const TextStyle(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              commentDropDown(setState), 
              IconButton(icon: const Icon(Icons.send, color: SpecialColors.commentTextcolor), onPressed: () => addComment(commentController.text),),
            ]
          ),
        ]
      )
    );
  }

  Widget commentDropDown([void Function(VoidCallback fn)? setState]){
    return DropdownMenu(
      trailingIcon: const Icon(Icons.person, color: SpecialColors.commentTextcolor),
      selectedTrailingIcon: const Icon(Icons.person, color: SpecialColors.commentTextcolor),
      width: 50,
      textStyle: const TextStyle(fontSize: 0),
      initialSelection: selectedMember,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(15),),
      ),
      menuStyle: MenuStyle(
        fixedSize: WidgetStateProperty.all(Size.fromWidth(nameMaxLength)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      ),
      dropdownMenuEntries: List.generate(
        members.length, 
        (index) {
          return DropdownMenuEntry(
            label: members[index].name,
            value: index+1,
          );
        }
      ),
      onSelected: (value) {
        (setState ?? this.setState)(() {
          selectedMember = value ?? 1;
        });
      },
    );
  }

  Widget comment(Comment comment, int i){
    const emptySpace = "                   ‎";
    final commentController = TextEditingController(text: "${comment.text}$emptySpace");
    final memberName = "${members.firstWhere((element) => element.id == comment.memberId).name}$emptySpace";

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color(members.firstWhere((element) => element.id == comment.memberId).color),
          ),
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    readOnly: !editComment[i],
                    maxLines: null,
                    style: const TextStyle(fontSize: 15, color: SpecialColors.commentTextcolor),
                    controller: commentController,
                    decoration: const InputDecoration(isDense: true, border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, disabledBorder: InputBorder.none),
                  ),
                  Text(memberName, style: const TextStyle(fontSize: 10, color: SpecialColors.commentTextcolor)),
                ]
              )
        ),
        Positioned(
          right: 0, 
          bottom: 0, 
          child: Padding(padding: const EdgeInsets.all(10), 
            child: Row(
              children: [
                editComment[i] ? IconButton(
                  onPressed: () {
                    comment.text = commentController.text.replaceAll("‎", "");
                    comment.text = comment.text.trim();
                    if (comment.text != '') {
                      DatabaseHelper.instance.updateComment(Comment(id: comment.id, text: comment.text, bookId: comment.bookId, memberId: comment.memberId));
                      setState(() => editComment[i] = !editComment[i]);
                    }
                  },
                  icon: const Icon(Icons.check, color: SpecialColors.commentTextcolor, size: 15)
                ) : IconButton(
                    onPressed: () => showDeleteDialog(comment), 
                    icon: const Icon(Icons.delete, color: SpecialColors.commentTextcolor, size: 15)
                ),
                IconButton(
                  onPressed: () => setState(() => editComment[i] = !editComment[i]), 
                  icon: Icon(editComment[i] ? Icons.close : Icons.edit, color: SpecialColors.commentTextcolor, size: 15)
                )
              ]
            )
          ),
        ),
      ],
    );
  }

  Widget commentBoard(){
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(parent:AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.only(top: 10),
            itemCount: comments.length,
            itemBuilder: (BuildContext context, int i) {
              return Align(
                alignment: Alignment.topLeft,
                child: comment(comments[i], i),
              );
            },
          ),
        ),
        commentField()
      ]
    );
  }

  Widget phone(){
    return CustomDialog(
      fullWindow: true,
      content: commentBoard(),
    );
  }

  Widget desktop(){
    return commentBoard();
  }

  @override
  Widget build(BuildContext context) {
    comments = widget.comments;

    return widget.device == Device.phone ? phone() : desktop();
  }
}
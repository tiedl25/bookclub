import 'package:bookclub/database.dart';
import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/progress.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter/services.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({super.key, required this.book, required this.progress, required this.updateProgress});
  final Progress progress;
  final Book book;
  final Function updateProgress;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  late final Progress progress;
  late final Book book;
  late final Function updateProgress;

  @override
  void initState() {
    super.initState();
    progress = widget.progress;
    book = widget.book;
    updateProgress = widget.updateProgress;
  }


  Future<void> updatePage(Progress progress) async {
    DatabaseHelper.instance.updateProgress(progress);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController currentPageController = TextEditingController(text: progress.page.toString());
    TextEditingController maxPagesController = TextEditingController(text: (progress.maxPages ?? book.pages).toString());

    currentPageController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: currentPageController.text.length,
    );

    return CustomDialog(
      title: const Text(CustomStrings.updateDialogTitle),
      content: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: const InputDecoration(labelText: 'Current page'),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              autofocus: true,
              controller: currentPageController,
            ),
          ),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(labelText: 'Max. pages'),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[1-9][0-9]*'))],
              keyboardType: TextInputType.number,
              controller: maxPagesController,
            )
          )
        ]
      ),
      submitButton: TextButton(
        child: Text("Update", style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium!.fontSize)),
        onPressed: () {
          int oldPage = progress.page;
          int nr = int.parse(currentPageController.text);
          nr = nr < 0 ? 0 : nr;
          int maxNr = int.parse(maxPagesController.text);
          progress.page = nr > maxNr ? maxNr : nr;
          progress.maxPages = maxNr < 1 ? 1 : maxNr;
          updatePage(progress);
          updateProgress(progress);
          Navigator.of(context).pop(progress.page == (progress.maxPages ?? book.pages) && progress.page != oldPage);
        }
      )
    );
  }
}
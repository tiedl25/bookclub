import 'package:bookclub/database.dart';
import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/models/book.dart';
import 'package:bookclub/models/member.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:bookclub/utils.dart';
import 'package:flutter/material.dart';

class AddDialog extends StatefulWidget {
  final Book lastBook;
  final List<Member> members;
  final Function() updateBooks;

  const AddDialog({super.key, required this.lastBook, required this.members, required this.updateBooks});

  @override
  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  final _formKey = GlobalKey<FormState>();

  late String title;
  late String author;
  late int pageNr;
  late String description;
  late String imagePath;

  DateTimeRange getDateRange(){
    DateTime startDate = widget.lastBook.to!.add(const Duration(days: 1));
    DateTime endDate = DateTime(startDate.year, startDate.month + 3, 0);
    return DateTimeRange(start: startDate, end: endDate);
  }

  int getProviderId(){
    final lastProviderId = widget.lastBook.providerId;
    widget.members.sort((a, b) => b.birthDate.compareTo(a.birthDate));
    final lastProviderIndex = widget.members.indexWhere((element) => element.id == lastProviderId);
    return widget.members[lastProviderIndex+1].id!;
  }

  void addBook() async {
    if(!_formKey.currentState!.validate()){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(CustomStrings.addDialogValidationError)));
    }
    
    _formKey.currentState!.save();

    DateTimeRange dateRange = getDateRange();
    int providerId = getProviderId();

    /*
    Add progresses for every user
    */

    await DatabaseHelper.instance.addBook(
      Book(
        name: title,
        author: author,
        description: description,
        image_path: imagePath,
        pages: pageNr,
        from: dateRange.start,
        to: dateRange.end,
        providerId: providerId,
      )
    );

    widget.updateBooks();
  }

  validateFormField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  validateIntFormField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    } else if (int.tryParse(value) == null) {
      return 'Please enter a number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      fullWindow: true,
      title: const Text(CustomStrings.addDialogTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                validator: (String? value) => validateFormField(value),
                decoration: textFieldDecoration('Title'),
                onSaved: (newValue) => title = newValue!,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                validator: (String? value) => validateFormField(value),
                decoration: textFieldDecoration('Author'),
                onSaved: (newValue) => author = newValue!,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                keyboardType: TextInputType.number,
                validator: (String? value) => validateFormField(value),
                decoration: textFieldDecoration('Nr of Pages'),
                onSaved: (newValue) => pageNr = int.parse(newValue!),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                minLines: 7,
                maxLines: 12,
                validator: (String? value) => validateFormField(value),
                decoration: textFieldDecoration('Description'),
                onSaved: (newValue) => description = newValue!,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextFormField(
                validator: (String? value) => validateFormField(value),
                decoration: textFieldDecoration('Link to image'),
                onSaved: (newValue) => imagePath = newValue!,
              ),
            ),
          ],
        ),
      ),
      submitButton: TextButton(
        child: const Text(CustomStrings.addSubmitButton),
        onPressed: () => { addBook(), Navigator.of(context).pop() },
      ),
    );
  }
}
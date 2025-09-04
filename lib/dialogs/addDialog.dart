import 'package:bookclub/bloc/masterview_bloc.dart';
import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:bookclub/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddDialog extends StatelessWidget {
  late BuildContext context;
  late MasterViewCubit cubit;

  final _formKey = GlobalKey<FormState>();

  late String title;
  late String author;
  late int pageNr;
  late String description;
  late String imagePath;

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
    context = context;
    cubit = context.read<MasterViewCubit>();

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
        onPressed: () => [cubit.addBook(_formKey, title, author, pageNr, description, imagePath), Navigator.of(context).pop()],
      ),
    );
  }
}
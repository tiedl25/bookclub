import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/result.dart';
import 'package:flutter/material.dart';

import 'database.dart';

Future<bool> showLoginDialog(setState, context, [title]) async {
  if(await DatabaseHelper.instance.checkLogin()) return true;

  final pinController = TextEditingController();

  return await showDialog(context: context, builder: (builder){
    return CustomDialog(
      title: Text(title ?? 'Login'),
      content: TextField(
        keyboardType: TextInputType.number,
        controller: pinController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'PIN',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
        ),
      ),
      submitButton: TextButton(
        onPressed: () => DatabaseHelper.instance.loginWithPin(pinController.text).then((Result result) {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? '')));
            
          });if (result.isSuccess) Navigator.of(context).pop(result.isSuccess);
          }),
        child: const Text('Login')
      )
    );
  }
  ) as bool;
}

OutlineInputBorder get textFieldBorder => OutlineInputBorder(
  borderSide: BorderSide.none, 
  borderRadius: BorderRadius.circular(15),
);

InputDecoration textFieldDecoration(String hintText) => InputDecoration(
  contentPadding: const EdgeInsets.all(10),
  filled: true,
  hintText: hintText,
  border: textFieldBorder,
);
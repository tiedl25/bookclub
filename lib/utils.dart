import 'dart:async';

import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/result.dart';
import 'package:flutter/material.dart';

import 'database.dart';

Future<bool?> showLoginDialog(cubit, context, [title]) async {
  if(await DatabaseHelper.instance.checkLogin()) return true;

  return await showDialog(context: context, builder: (builder){
    return CustomDialog(
      title: Text(title ?? 'Login'),
      content: TextField(
        keyboardType: TextInputType.number,
        controller: cubit.state.pinController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'PIN',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
        ),
      ),
      submitButton: TextButton(
        onPressed: () => cubit.login().then((result) => result ? Navigator.of(context).pop(result) : null),
        child: const Text('Login')
      )
    );
  }
  ) as bool?;
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

void showOverlayMessage({
  required BuildContext context,
  required String message,
  Duration duration = const Duration(seconds: 3),
  Color backgroundColor = Colors.black,
  Color textColor = Colors.white,
}) {
  
  final overlayEntry = OverlayEntry(
    builder: (context) => SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 10,
            left: 10,
            right: 10,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  Timer(duration, () => overlayEntry.remove());
}
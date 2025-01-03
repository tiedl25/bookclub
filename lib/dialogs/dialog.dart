import 'dart:ui';

import 'package:bookclub/resources/colors.dart';
import 'package:flutter/material.dart';

enum Device {
  phone,
  desktop,
}

class CustomDialog extends StatelessWidget {
  final Widget? title;
  final Widget content;
  final bool fullWindow;
  final Widget? submitButton;
  final double padding;

  const CustomDialog({
    super.key,
    required this.content,
    this.title,
    this.fullWindow = false,
    this.submitButton,
    this.padding = 20,
  });

  Widget column(){
    return Column(
      mainAxisSize: fullWindow ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) DefaultTextStyle(style: const TextStyle(fontSize: 25), child: title!),
        if (title != null) SizedBox(height: padding),
        Flexible(child: content),
        if (submitButton != null) SizedBox(height: padding),
        if (submitButton != null) DefaultTextStyle(style: const TextStyle(fontSize: 20), child: submitButton!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Dialog(
        insetPadding: title == null ? const EdgeInsets.all(15) : null,
        child: SizedBox(
          height: fullWindow ? MediaQuery.of(context).size.height : null,
          width: fullWindow ? MediaQuery.of(context).size.width : null,
          child: Stack(
            children: [
              Padding(
                padding: title == null ? const EdgeInsets.all(5) : EdgeInsets.all(padding), 
                child: column()
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SpecialColors.closeButtonBackground,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: SpecialColors.closeButton,
                    ),
                  ),
                ),
              ),
            ]
          ),
        )
      ),
    );
  }
}
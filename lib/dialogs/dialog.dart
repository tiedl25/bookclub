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
  final double? margin;
  final Color? backgroundColor;
  final double? width;
  final EdgeInsets? insetPadding;
  late BuildContext context;

  CustomDialog({
    super.key,
    required this.content,
    this.title,
    this.fullWindow = false,
    this.submitButton,
    this.padding = 20,
    this.margin,
    this.backgroundColor,
    this.width,
    this.insetPadding,
  });

  Widget column(){
    return Column(
      mainAxisSize: fullWindow ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) DefaultTextStyle(style: Theme.of(context).textTheme.titleLarge!, child: title!),
        if (title != null) SizedBox(height: padding),
        content,
        if (submitButton != null) ...[
          if (fullWindow) const Spacer(),
          const SizedBox(height: 10),
          submitButton!,
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;

    return PopScope(
      onPopInvokedWithResult: (_, confirmed) => confirmed is bool ? confirmed : false,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Dialog(
          insetPadding: insetPadding ?? (fullWindow ? const EdgeInsets.all(15) : (title == null ? const EdgeInsets.all(15) : null)),
          child: SizedBox(
            height: fullWindow ? MediaQuery.of(context).size.height : null,
            width: fullWindow ? MediaQuery.of(context).size.width : width ?? double.minPositive,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: backgroundColor ?? Theme.of(context).dialogBackgroundColor,
                  ),
                  padding: EdgeInsets.all(padding), 
                  child: column()
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
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
      ),
    );
  }
}
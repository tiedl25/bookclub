import 'package:bookclub/bloc/masterview_bloc.dart';
import 'package:bookclub/bloc/masterview_states.dart';
import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:flutter/material.dart' hide Dialog;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateDialog extends StatelessWidget {
  late BuildContext context;
  late MasterViewCubit cubit;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    cubit = context.read<MasterViewCubit>();

    return BlocBuilder<MasterViewCubit, MasterViewState>(
      buildWhen: (previous, current) => current is MasterViewUpdateDialog,
      builder: (context, state) {
        state as MasterViewUpdateDialog;
        return CustomDialog(
            title: const Text(CustomStrings.updateDialogTitle),
            content: Row(children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: const InputDecoration(labelText: 'Current page'),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  controller: state.currentPageController,
                ),
              ),
              Expanded(
                  child: TextField(
                decoration: const InputDecoration(labelText: 'Max. pages'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[1-9][0-9]*'))
                ],
                keyboardType: TextInputType.number,
                controller: state.maxPagesController,
              ))
            ]),
            submitButton: TextButton(
                child: Text("Update",
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleMedium!.fontSize)),
                onPressed: () async => [Navigator.pop(context), await cubit.updateProgress()]));
      },
    );
  }
}

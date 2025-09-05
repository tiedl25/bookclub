import 'package:bookclub/bloc/profileDialog_bloc.dart';
import 'package:bookclub/bloc/profileDialog_states.dart';
import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

class ProfileDialog extends StatelessWidget {
  final bool isPhone;
  const ProfileDialog({Key? key, required this.isPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileDialogCubit, ProfileDialogState>(
        buildWhen: (_, current) => current is ProfileDialogLoaded || current is ProfileDialogLoading || current is ProfileDialogError,
        builder: (context, state) {
          return CustomDialog(
            insetPadding: EdgeInsets.all(isPhone ? 10 : 15),
            width: MediaQuery.of(context).size.width * (isPhone ? 0.9 : 0.5),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: state.member.profilePicture != null
                    ? MemoryImage(state.member.profilePicture!)
                        as ImageProvider<Object>
                    : const AssetImage('assets/images/pp_placeholder.jpeg'),
                ),
                const SizedBox(width: 20),
                Text(state.member.name, style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            content: state is ProfileDialogLoaded
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(CustomStrings.myOtherBooks, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: state.books.length,
                      itemBuilder: (context, index) {
                        final book = state.books[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: book.imagePath != null
                                  ? Image.network(
                                      scale: 1.0,
                                      //width: 100,
                                      //height: 150,
                                      book.imagePath!,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.name ?? 'Unknown',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'by ${book.author ?? "Unknown"} (${book.pages ?? 0} pages)',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Html(
                                      data: book.description!,
                                      style: {
                                        "body": Style(
                                          maxLines: 10,
                                          textOverflow: TextOverflow.ellipsis,
                                          fontSize: FontSize.medium,
                                        ),
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
              : state is ProfileDialogLoading ? const Center(child: CircularProgressIndicator()) : Text((state as ProfileDialogError).message, style: Theme.of(context).textTheme.bodyLarge),);
        });
  }
}
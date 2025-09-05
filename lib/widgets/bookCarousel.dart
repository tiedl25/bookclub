import 'package:bookclub/bloc/masterview_bloc.dart';
import 'package:bookclub/bloc/masterview_states.dart';
import 'package:bookclub/dialogs/addDialog.dart';
import 'package:bookclub/dialogs/dialog.dart';
import 'package:bookclub/models/book.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookCarousel extends StatelessWidget {
  late BuildContext context;
  late MasterViewCubit cubit;
  final double aspRat;
  final bool phone;
  late Book book;

  BookCarousel({super.key, required this.aspRat, required this.phone});

  bool defaultBook(DateTime? date) => date == null;

  void showDescriptionDialog() {
    showDialog(
      context: context,
      builder: (builder) {
        return CustomDialog(
          backgroundColor: Color(book.color!),
          content: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: description(book)));
      });
  }

  void showAddDialog() {
    showDialog(
        context: context,
        builder: (builder) {
          return BlocProvider.value(
            value: cubit,
            child: AddDialog(),
          );
        });
  }

  Widget description(Book i) => SingleChildScrollView(
    child: SelectableText(i.description ?? '',
        onTap: () => cubit.toggleDescription(i.id!, phone),
        style: TextStyle(
            color: Color(i.color!).computeLuminance() > 0.2
                ? Colors.black
                : Colors.white)));

  Widget bookPlaceholder(state) =>state.admin! && state.book == state.books.last
    ? Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/book_placeholder.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: GestureDetector(
        onTap: () => showAddDialog(),
        child: const Center(
          child: Icon(Icons.add, color: Colors.black, size: 100),
        ),
      ))
    : Image.asset('assets/images/book_placeholder.jpeg');

  @override
  Widget build(BuildContext context) {
    this.context = context;
    this.cubit = context.read<MasterViewCubit>();

    return BlocConsumer<MasterViewCubit, MasterViewState>(
      listenWhen: (_, current) => current is MasterViewListener,
      listener: (context, state) {
        switch (state.runtimeType) {
          case const (MasterViewShowDescriptionDialog):
            showDescriptionDialog();
            break;
        }
      },
      buildWhen: (_, current) => current is MasterViewLoaded,
      builder: (context, state) {
        state as MasterViewLoaded;
        book = state.book;

        return CarouselSlider(
          carouselController: state.carouselSliderController,
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height / (aspRat < 1 ? 3 : 2),
            viewportFraction: phone ? 0.25 / aspRat : 0.4 / aspRat,
            initialPage: state.books.indexWhere((b) => b.id == state.book.id),
            enableInfiniteScroll: false,
            reverse: false,
            autoPlay: false,
            enlargeCenterPage: true,
            enlargeFactor: 0.25,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) => cubit.changePage(index),
          ),
          items: state.books.map<Widget>((i) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                onTap: () => cubit.showDescriptionDialog(i, phone),
                child: !defaultBook(i.from) &&
                    state.showDescription &&
                    i.id == state.book.id
                  ? Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Color(i.color!)),
                    child: description(i))
                  : Stack(children: [
                    !defaultBook(i.from)
                        ? CachedNetworkImage(
                            imageUrl: i.image_path!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => CircularProgressIndicator(
                              color: Color(i.color!),
                            ),
                            errorWidget: (context, url, error) =>
                                bookPlaceholder(state),
                        )
                        : bookPlaceholder(state),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: CircleAvatar(
                            radius: phone ? 20 : 30,
                            backgroundImage: state.members
                                        .firstWhere(
                                            (m) => m.id == i.providerId)
                                        .profilePicture !=
                                    null
                                ? MemoryImage(
                                        state.members
                                            .firstWhere(
                                                (m) => m.id == i.providerId)
                                            .profilePicture!)
                                    as ImageProvider<Object>
                                : const AssetImage(
                                    'assets/images/pp_placeholder.jpeg'),
                          ),
                        ))
                    ]),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
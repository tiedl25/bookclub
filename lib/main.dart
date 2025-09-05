import 'package:bookclub/bloc/masterview_bloc.dart';
import 'package:bookclub/resources/colors.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Views/masterview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

ThemeMode currentTheme = ThemeMode.system;

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: CustomStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: currentTheme == ThemeMode.light ? lighttheme : darktheme,
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => MasterViewCubit((value) => setState(() {
          currentTheme = value;
        })),
        child: MasterView(),
      ),
    );
  }
}

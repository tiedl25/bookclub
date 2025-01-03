import 'package:bookclub/resources/colors.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:flutter/material.dart';
import 'Views/masterview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: CustomStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: CustomStrings.appDesription),
    );
  }
}

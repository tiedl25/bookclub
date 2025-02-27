import 'package:bookclub/resources/colors.dart';
import 'package:bookclub/resources/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Views/masterview.dart';

void main() async {
  await dotenv.load(fileName: ".env");
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
      home: MyHomePage(title: CustomStrings.appDesription, changeTheme: (value) => setState(() => currentTheme = value),),
    );
  }
}

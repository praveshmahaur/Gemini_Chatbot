import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
// import 'package:gemini_app/constant.dart';
import 'package:gemini_app/home_screen.dart';

Future main() async{
  // await dotenv.load(fileName: ".env");
  // Gemini.init(apiKey: env['API_KEY']);
  Gemini.init(apiKey: "AIzaSyCOB-1hI-i7rX8-f1uYLqK0lMeXyzZ8fJo");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gemini App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        //brightness: Brightness.dark
      ),
      home: const HomeScreen(),
    );
  }
}

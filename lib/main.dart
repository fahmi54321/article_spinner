import 'package:article_spinner/text_spinner_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TextSpinnerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

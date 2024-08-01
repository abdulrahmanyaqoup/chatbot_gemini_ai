import 'package:chatbot_gemini_ai/View/chatbot_page.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat Bot App',
      theme: FlexThemeData.light(
        scheme: FlexScheme.blueM3,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.blueM3,
      ),
      themeMode: ThemeMode.system,
      home: const ChatBotPage(),
    );
  }
}

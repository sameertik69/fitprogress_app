import 'package:flutter/material.dart';

import 'screens/start_page.dart';

void main() {
  runApp(const FitProgressApp());
}

class FitProgressApp extends StatelessWidget {
  const FitProgressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitProgress AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1f7a5a)),
      ),
      home: const StartPage(),
    );
  }
}

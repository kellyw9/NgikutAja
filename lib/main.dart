import 'package:flutter/material.dart';
import 'travel_mode/travel_mode_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NgikutAja',
      debugShowCheckedModeBanner: false,
      home: const TravelModePage(),
    );
  }
}
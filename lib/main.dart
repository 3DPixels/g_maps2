import 'package:flutter/material.dart';
import 'package:g_maps2/pages/map_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Google Maps Applications',
      home: MapPage(),
    );
  }
}

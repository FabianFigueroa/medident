// home-desktop.dart - Desktop layout for home screen
import 'package:flutter/material.dart';
import 'package:medident/main_export.dart';

class HomeDesktop extends StatelessWidget {
  const HomeDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medident'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Home - Desktop View',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

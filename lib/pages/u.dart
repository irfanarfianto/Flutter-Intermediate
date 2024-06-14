import 'package:flutter/material.dart';

class UnknownScreen extends StatelessWidget {
  const UnknownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unknown Page'),
      ),
      body: const Center(
        child: Text(
          'Unknown Page Content',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

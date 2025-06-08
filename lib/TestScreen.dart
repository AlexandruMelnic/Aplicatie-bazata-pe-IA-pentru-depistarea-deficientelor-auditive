import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  final String testName;

  TestScreen({required this.testName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(testName)),
      body: Center(
        child: Text(
          'Aici va fi implementat testul: $testName',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:taksi/services/drawer/drawer.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyCustomDrawer(),
      appBar: AppBar(),
      body: Column(
        children: [],
      ),
    );
  }
}

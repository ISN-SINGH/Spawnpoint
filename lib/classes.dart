import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClassesPage extends StatefulWidget {
  final User user;

  ClassesPage({Key? key, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Name")),
      body: Center(child: Text("This is where we view classes"))
    );
  }
}
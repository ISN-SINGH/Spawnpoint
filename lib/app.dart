import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/classes.dart';
import 'package:testing/profile.dart';

class App extends StatefulWidget {
  final User user;

  const App({Key? key, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  int _index = 0; // tells us which navigation pane we are on

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScaffoldBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Classes"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profile")
        ],
        onTap: (index) => setState(() => _index = index),
        currentIndex: _index,
      ),
    );
  }

  Widget _buildScaffoldBody() {
    switch (_index) {
      case 0:
        return ClassesPage(user: widget.user);
      case 1:
        return ProfilePage(user: widget.user);
      default:
        throw Exception();
    }
  }
}
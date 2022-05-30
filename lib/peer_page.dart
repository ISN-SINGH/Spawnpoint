import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'firebase_user_object.dart';

class PeerPage extends StatefulWidget {
  final FirebaseFirestore db;
  final String classID;

  PeerPage({Key? key, required this.db, required this.classID}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PeerPageState();
}

class _PeerPageState extends State<PeerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Peers"),
      ),
      body: Column(children: [
        //FutureBuilder(builder: builder) - peer card for each friend
      ],),
    );
  }

}

class PeerCard extends StatefulWidget {
  final UserObj peer;
  
  PeerCard({Key? key, required this.peer}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PeerPageState();
}

class _PeerCardState extends State<PeerCard> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  
}
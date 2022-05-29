import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/class_api.dart';
import 'package:testing/class_object.dart';
import 'package:testing/firebase_user_object.dart';

class ClassesPage extends StatefulWidget {
  final User user;
  final FirebaseFirestore db;
  List<String> classes = List<String>.empty(growable: true);

  ClassesPage({Key? key, required this.user, required this.db}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Classes")),
      body: FutureBuilder(
        future: widget.db.collection("users")
          .doc(widget.user.email)
          .withConverter(fromFirestore: UserObj.fromFirestore, toFirestore: (UserObj userObj, _) => userObj.toFirestore())
          .get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot<UserObj>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.data()!.classes == null) {
              return const Center(child: Text("You have no classes in your schedule"));
            } else {
              print(snapshot.data!.data()!.classes!); // TODO remove
              return FutureBuilder(
                future: classListByIDs(snapshot.data!.data()!.classes!),
                builder: (context, AsyncSnapshot<List<ClassObj>> new_snapshot) {
                  //print(new_snapshot.data!); // TODO remove
                  if (new_snapshot.hasData) {
                    return ListView.builder(
                      itemCount: new_snapshot.data!.length,
                      itemBuilder: (context, index) => ClassCard(classObj: new_snapshot.data![index]),
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              );
            }

          }
          return const Center(child: CircularProgressIndicator());
        },
      )
    ); // add floating action button for adding classes
  }
}

class ClassCard extends StatefulWidget {
  final ClassObj classObj;

  ClassCard({Key? key, required this.classObj}) : super(key: key);

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell( // add functionality to delete class with long hold?
        onTap: () { /* open new page to show all app users in selected class */ },
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(widget.classObj.code!)
            ],
          ),
        ),
      ),
    );
  }

}
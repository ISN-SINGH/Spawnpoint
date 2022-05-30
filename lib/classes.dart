import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/class_add_page.dart';
import 'package:testing/class_api.dart';
import 'package:testing/class_object.dart';
import 'package:testing/firebase_user_object.dart';
import 'package:testing/peer_page.dart';

class ClassesPage extends StatefulWidget {
  final User user;
  final FirebaseFirestore db;
  List<ClassObj> classes = List<ClassObj>.empty(growable: true);

  ClassesPage({Key? key, required this.user, required this.db}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  late bool triggerStateChange;

  @override
  void initState() {
    triggerStateChange = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Classes")),
      body: FutureBuilder( // Get ids of all classes of user
        future: widget.db.collection("users")
          .doc(widget.user.email)
          .withConverter(fromFirestore: UserObj.fromFirestore, toFirestore: (UserObj userObj, _) => userObj.toFirestore())
          .get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot<UserObj>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.data()!.classes == null) {
              return const Center(child: Text("You have no classes in your schedule"));
            } else {
              return FutureBuilder( // Get ClassObjs for each class id of user and display
                future: classListByIDs(snapshot.data!.data()!.classes!),
                builder: (context, AsyncSnapshot<List<ClassObj>> new_snapshot) {
                  if (new_snapshot.hasData) {
                    widget.classes = new_snapshot.data!;
                    return Scaffold(
                      body: ListView.builder(
                          itemCount: new_snapshot.data!.length,
                          itemBuilder: (context, index) => ClassCard(classObj: new_snapshot.data![index], db: widget.db, canRedirect: true),
                      ),
                      floatingActionButton: FloatingActionButton( // Go to page to add new classes
                          child: Icon(Icons.add),
                          onPressed: () async {
                            final value = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  ClassAdd(db: widget.db, currClasses: widget.classes, user: widget.user)));
                            setState(() { // forces ui to change after returning from add classes page
                              triggerStateChange = triggerStateChange == false ? true : false;
                            });
                          })
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
  final FirebaseFirestore db;
  final bool canRedirect;

  ClassCard({Key? key, required this.classObj, required this.db, required this.canRedirect}) : super(key: key);

  @override
  State<ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<ClassCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [Material(
              // type: MaterialType.transparency,
              // color: Colors.teal.shade50,
              child: InkWell( // add functionality to delete class with long hold?
                onTap: () {},// onTap: () => Navigator.push( // go to page to see peers in class only if redirect true
                //     context,
                //     MaterialPageRoute(builder: (context) => PeerPage(db: widget.db, classID: widget.classObj.id!))
                // ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            widget.classObj.code! + " - " + widget.classObj.title!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                        Text(
                            "Instructors: " + widget.classObj.instructors!.join(", "),
                            style: const TextStyle(fontSize: 14.0))
                      ],
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Units: " + widget.classObj.minUnits.toString(),
                          style: const TextStyle(fontSize: 14.0)
                        ),
                        Text(
                            "Sections: " + widget.classObj.sections!.length.toString(),
                            style: const TextStyle(fontSize: 14.0))
                      ],
                    )
                  ],
                ),
              ),
            )]
        )
    );
  }

}
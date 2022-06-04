import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/class_api.dart';
import 'package:testing/class_object.dart';
import 'package:testing/classes.dart';

class ClassAdd extends StatefulWidget {
  final List<ClassObj> currClasses;
  final FirebaseFirestore db;
  final User user;

  ClassAdd({Key? key, required this.db, required this.currClasses, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ClassAddState();
}

class _ClassAddState extends State<ClassAdd> {
  final _classController = TextEditingController();
  late int initNumClasses;
  late String _query;

  @override
  void initState() {
    _query = "";
    initNumClasses = widget.currClasses.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Add Classes"),
          leading: BackButton(
            color: Colors.white,
            onPressed: () async { // If new classes, add them to firestore db
              if (widget.currClasses != initNumClasses) {
                List<String> ids = List<String>.empty(growable: true);
                for (var temp_class in widget.currClasses) {
                  ids.add(temp_class.id!);
                }
                await widget.db.collection("users")
                    .doc(widget.user.email)
                    .set({"classes": ids}, SetOptions(merge: true));
              }

              Navigator.pop(context);
            },
          )
      ),
      body: Column(
        children: [
          Row( // search bar and button
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 500,
                child: TextField(
                  controller: _classController,
                  decoration: InputDecoration(hintText: "Search by course title/instructor")
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _query = _classController.text;
                    });
                  },
                  child: Icon(Icons.manage_search))
            ],
          ),
          Padding(padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: MediaQuery.of(context).size.width * 0.25),
              child: queriedClasses(_query))
        ],
      )
    );
  }

  Widget queriedClasses(String query) {
    if (query == "") {
      return Container();
    }

    return FutureBuilder(
      future: classList(query),
      builder: (context, AsyncSnapshot<List<ClassObj>> snapshot) {
        if (snapshot.hasData) {
          return ListView.separated(
            separatorBuilder: (context, index) {
              return SizedBox(height: 10);
            },
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => _queriedClassCard(snapshot.data![index]),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _queriedClassCard(ClassObj classObj) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
      Expanded(child: ClassCard(classObj: classObj, db: widget.db, canRedirect: false, user: widget.user)),
      Container(margin: EdgeInsets.only(left: 10),
        child: ElevatedButton(
            onPressed: () { // alert user whether or not class was added/class is already present
              for (var temp_class in widget.currClasses) {
                if (temp_class.id == classObj.id) {
                  showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                    title: Text("Schedule Alert"),
                    content: Text("This class is already present in your schedule"),
                    actions: [TextButton(onPressed: () => Navigator.pop(context, 'OK'), child: Text("OK"))],
                  ));
                  return;
                }
              }
              showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                title: Text("Schedule Alert"),
                content: Text("Class added to schedule"),
                actions: [TextButton(onPressed: () => Navigator.pop(context, 'OK'), child: Text("OK"))],
              ));
              widget.currClasses.add(classObj);
            },
            child: Icon(Icons.add)),
      )
    ],);
  }

}
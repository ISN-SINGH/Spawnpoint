import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testing/class_api.dart';
import 'package:testing/class_object.dart';
import 'package:testing/classes.dart';

class ClassAdd extends StatefulWidget {
  final List<ClassObj> currClasses;
  final FirebaseFirestore db;

  ClassAdd({Key? key, required this.db, required this.currClasses}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ClassAddState();
}

class _ClassAddState extends State<ClassAdd> {
  final _classController = TextEditingController();
  late String _query;

  @override
  void initState() {
    _query = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Classes")),
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
          Container(
            margin: EdgeInsets.only(top: 50.0),
            child: queriedClasses(_query),
          )
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
          return ListView.builder(
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
    return Row(children: [
      ClassCard(classObj: classObj, db: widget.db, canRedirect: false),
      ElevatedButton(
          onPressed: () {},
          child: Icon(Icons.add))
    ],);
  }

}
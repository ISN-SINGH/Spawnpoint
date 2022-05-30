import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/firebase_user_object.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  final FirebaseFirestore db;


  ProfilePage({Key? key, required this.user, required this.db}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserObj thisUser; // UserObj of profile to display
  late bool isCurrUser; // if profile page is of the current logged in user
  late bool majorChanged, bioChanged, hobbiesChanged, socialsChanged; // update database if change

  // display profile page changes through local variables, update at end
  late String thisUser_name;
  late String thisUser_photoUrl;
  late List<String> thisUser_majors;
  late String thisUser_bio;
  late String thisUser_hobbies;
  late Map<String, dynamic> thisUser_socials;

  @override
  void initState() async {
    final docSnap = await widget.db.collection("users").doc(widget.user.email)
      .withConverter(fromFirestore: UserObj.fromFirestore, toFirestore: (UserObj userObj, _) => userObj.toFirestore())
      .get();
    thisUser = docSnap.data()!;

    isCurrUser = thisUser.email == widget.user.email;
    thisUser_name = thisUser.name!;
    thisUser_photoUrl = thisUser.photoUrl!;
    //thisUser_majors = thisUser.majors

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCurrUser) {
      return Scaffold();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("App Name")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //TODO: stop trolling and add actual default name/image if photourl/displayName are null
            Image.network(widget.user.photoURL ?? "https://play-lh.googleusercontent.com/8ddL1kuoNUB5vUvgDVjYY3_6HwQcrg1K2fd_R8soD-e2QYj8fT9cfhfh3G0hnSruLKec"),
            Text(widget.user.displayName ?? "susquestionmark")
          ],
        )
      )
    );
  }

}
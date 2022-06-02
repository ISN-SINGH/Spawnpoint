import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/firebase_user_object.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  final FirebaseFirestore db;
  final String profileUserId; // email of user or profile to display


  ProfilePage({Key? key, required this.user, required this.db, required this.profileUserId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late bool isCurrUser; // if profile page is of the current logged in user
  late bool changesMade; // update database if change

  // display profile page changes through local variables, update at end
  late UserObj profileObj;

  @override
  void initState() {
    isCurrUser = widget.profileUserId == widget.user.email;

    changesMade = false;

    profileObj = UserObj.simple("null", "null", "null");


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCurrUser) { // user won't be able to edit this profile because it isn't theirs TODO implement
      return Scaffold(

      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Your Profile")),
      body: FutureBuilder(
        future: _getProfile(),
        builder: (context, AsyncSnapshot<UserObj> snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: Column(crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 150.0),
                  Image.network(profileObj.photoUrl!),
                  Text(profileObj.name!),
                  SizedBox(height: 100.0),
                  Text("Majors: " + (profileObj.majors == null ? "Not set" : profileObj.majors!.join(", "))),
                  SizedBox(height: 50.0),
                  Text("Bio: " + (profileObj.bio ?? "Not set")),
                  SizedBox(height: 50.0),
                  Text("Hobbies: " + (profileObj.hobbies == null ? "Not set" : profileObj.hobbies!.join(", "))),
                  SizedBox(height: 150.0),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(width: 100.0, child: Image.asset("assets/images/insta_icon.png")),
                      Container(width: 100.0, child: Image.asset("assets/images/fb_icon.png")),
                      Container(width: 100.0, child: Image.asset("assets/images/snap_icon.png")),
                    ],
                  )
                ],
              )
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {

        },
      ),
    );
  }

  Future<UserObj> _getProfile () async {
    if (profileObj.email == "null") {
      return profileObj = (await widget.db.collection("users")
          .withConverter(fromFirestore: UserObj.fromFirestore, toFirestore: (UserObj userObj, _) => userObj.toFirestore())
          .doc(widget.profileUserId).get()).data()!;
    } else {
      return profileObj;
    }
  }


}

class ProfileEditPage extends StatefulWidget {
  final UserObj profileObj;

  ProfileEditPage({Key? key, required this.profileObj}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> { // todo finish edit page
  late TextEditingController _majorController;
  late TextEditingController _bioController;
  late TextEditingController _hobbiesController;

  @override
  void initState() { // add default values to controller if present
    _majorController = TextEditingController(
        text: widget.profileObj.majors == null ? null : widget.profileObj.majors!.join(", "));
    _bioController = TextEditingController(text: widget.profileObj.bio);
    _hobbiesController = TextEditingController(
        text: widget.profileObj.hobbies == null ? null : widget.profileObj.hobbies!.join(", "));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 150.0),
            Container(width: 500, child: TextField(
              controller: _majorController,
              decoration: InputDecoration(hintText: "Add your comma-separated majors"),
              maxLines: 1,
            )),
            Text(widget.profileObj.name!),
            SizedBox(height: 100.0),
            Text("Majors: " + (widget.profileObj.majors == null ? "Not set" : widget.profileObj.majors!.join(", "))),
            SizedBox(height: 50.0),
            Text("Bio: " + (widget.profileObj.bio ?? "Not set")),
            SizedBox(height: 50.0),
            Text("Hobbies: " + (widget.profileObj.hobbies == null ? "Not set" : widget.profileObj.hobbies!.join(", "))),
            SizedBox(height: 150.0),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: 100.0, child: Image.asset("assets/images/insta_icon.png")),
                Container(width: 100.0, child: Image.asset("assets/images/fb_icon.png")),
                Container(width: 100.0, child: Image.asset("assets/images/snap_icon.png")),
              ],
            )
          ],
        )
    );
  }

}
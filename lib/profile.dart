import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testing/firebase_user_object.dart';

//todo update database of new profile

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
  late bool triggerStateChange;

  @override
  void initState() {
    isCurrUser = widget.profileUserId == widget.user.email;
    changesMade = false;
    profileObj = UserObj.simple("null", "null", "null");
    triggerStateChange = false;


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
        onPressed: () async {
          final value = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileEditPage(profileObj: profileObj, onChangedProfile: (UserObj userObj) => profileObj = userObj)));
          setState(() { // forces ui to change
            triggerStateChange = triggerStateChange == false ? true : false;
          });
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




typedef OnChangedProfile = void Function(UserObj userObj);

class ProfileEditPage extends StatefulWidget {
  UserObj profileObj;
  final OnChangedProfile onChangedProfile;

  ProfileEditPage({Key? key, required this.profileObj, required this.onChangedProfile}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> { // todo finish edit page
  late TextEditingController _majorController;
  late TextEditingController _bioController;
  late TextEditingController _hobbiesController;

  late TextEditingController _linkInstaController;
  late TextEditingController _linkFBcontroller;
  late TextEditingController _linkSCcontroller;
  late String? linkInsta, linkFB, linkSC;

  @override
  void initState() { // add default values to controller if present


    _majorController = TextEditingController(
        text: widget.profileObj.majors == null ? null : widget.profileObj.majors!.join(", "));
    _bioController = TextEditingController(text: widget.profileObj.bio);
    _hobbiesController = TextEditingController(
        text: widget.profileObj.hobbies == null ? null : widget.profileObj.hobbies!.join(", "));

    _linkInstaController = TextEditingController();
    _linkFBcontroller = TextEditingController();
    _linkSCcontroller = TextEditingController();
    linkInsta = null; linkFB = null; linkSC = null;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Map<String, String> temp = {};
              if(nullIfEmpty(_linkInstaController.text) != null) temp["insta"] = nullIfEmpty(_linkInstaController.text)!;
              if(nullIfEmpty(_linkSCcontroller.text) != null) temp["snap"] = nullIfEmpty(_linkSCcontroller.text)!;
              if(nullIfEmpty(_linkFBcontroller.text) != null) temp["fb"] = nullIfEmpty(_linkFBcontroller.text)!;
              widget.onChangedProfile(UserObj(
                name: widget.profileObj.name,
                email: widget.profileObj.email,
                bio: nullIfEmpty(_bioController.text),
                photoUrl: widget.profileObj.photoUrl,
                majors: _majorController.text == "" ? null : _majorController.text.split(", "),
                hobbies: _hobbiesController.text == "" ? null : _hobbiesController.text.split(", "),
                socials: temp
              ));
              Navigator.pop(context);
            },
          )
      ),
      body: Container(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 150.0),
              Image.network(widget.profileObj.photoUrl!),
              Text(widget.profileObj.name!),
              SizedBox(height: 100.0),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 100, child: Text("Major:")),
                Container(width: 500, child: Material(
                  child: TextField(
                    controller: _majorController,
                    decoration: InputDecoration(hintText: "Ex: (Computer Science, Zoology, etc)"),
                    maxLines: 1,
                  ),
                )),
                SizedBox(width: 100)
              ]),

              SizedBox(height: 50.0),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 100, child: Text("Bio:")),
                Container(width: 500, child: Material(
                  child: TextField(
                    controller: _bioController,
                    decoration: InputDecoration(hintText: "Add your bio"),
                    maxLines: 2,
                  ),
                )),
                SizedBox(width: 100)
              ]),

              SizedBox(height: 50.0),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 100, child: Text("Hobbies:")),
                Container(width: 500, child: Material(
                  child: TextField(
                    controller: _hobbiesController,
                    decoration: InputDecoration(hintText: "Ex: (Video games, photography, etc)"),
                    maxLines: 1,
                  ),
                )),
                SizedBox(width: 100)
              ]),
              SizedBox(height: 150.0),
              Text("Tap an icon below to set redirect link"),
              SizedBox(height: 30.0),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(width: 100.0, child: GestureDetector( // insta
                      onTap: () {
                        showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                          title: Text("Add Social Media"),
                          content: TextField(
                            controller: _linkInstaController,
                            decoration: InputDecoration(hintText: "Insert link to Instagram profile"),
                          ),
                          actions: [TextButton(onPressed: () {linkInsta = _linkInstaController.text; Navigator.pop(context, 'Add');}, child: Text("Add")),
                                    TextButton(onPressed: () => Navigator.pop(context, 'Cancel'), child: Text("Cancel"))],
                        ));
                      },
                      child: Image.asset("assets/images/insta_icon.png"))),
                  Container(width: 100.0, child: GestureDetector( // FB
                      onTap: () {
                        showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                          title: Text("Add Social Media"),
                          content: TextField(
                            controller: _linkFBcontroller,
                            decoration: InputDecoration(hintText: "Insert link to Facebook profile"),
                          ),
                          actions: [TextButton(onPressed: () {linkFB = _linkFBcontroller.text; Navigator.pop(context, 'Add');}, child: Text("Add")),
                                    TextButton(onPressed: () => Navigator.pop(context, 'Cancel'), child: Text("Cancel"))],
                        ));
                      },
                      child: Image.asset("assets/images/fb_icon.png"))),
                  Container(width: 100.0, child: GestureDetector( // SC
                      onTap: () {
                        showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                          title: Text("Add Social Media"),
                          content: TextField(
                            controller: _linkSCcontroller,
                            decoration: InputDecoration(hintText: "Insert link to Snapchat profile"),
                          ),
                          actions: [TextButton(onPressed: () {linkSC = _linkSCcontroller.text; Navigator.pop(context, 'Add');}, child: Text("Add")),
                                    TextButton(onPressed: () => Navigator.pop(context, 'Cancel'), child: Text("Cancel"))],
                        ));
                      },
                      child: Image.asset("assets/images/snap_icon.png")))
                ],
              )
            ],
          )
      ),
    );
  }

  String? nullIfEmpty(String? string) {
    if (string == "") return null;
    return string;
  }

}
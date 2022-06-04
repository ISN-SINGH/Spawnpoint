import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'firebase_user_object.dart';

class PeerPage extends StatefulWidget { // todo class id search only works for one quarter
  final User user;
  final FirebaseFirestore db;
  final String classID;
  late List<UserObj> friends;

  PeerPage({Key? key, required this.db, required this.classID, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PeerPageState();
}

class _PeerPageState extends State<PeerPage> {
  late List<UserObj> peers;
  late bool peerCheck;
  late bool friendCheck;

  @override
  void initState() {
    peerCheck = false;
    friendCheck = false;
    peers = List<UserObj>.empty(growable: true);
    widget.friends = List<UserObj>.empty(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Peers"),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Peers"),
        FutureBuilder(
          future: _getPeers(),
          builder: (context, AsyncSnapshot<List<UserObj>?> snapshot) {
            if (snapshot.hasData) {
              if (peers.length == 0) {
                return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("You're the only one in this class!"),
                  SizedBox(height: 200)
                ],);
              } else {
                return Padding(padding: EdgeInsets.symmetric(vertical: 20, horizontal: MediaQuery.of(context).size.width * 0.25),
                  child: ListView.separated(
                      itemBuilder: (context, index) => _addFriendCard(peers[index]),
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 10);
                      },
                      itemCount: peers.length),
                );
              }
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        SizedBox(height: 50.0),
        Text("Friends"),
        FutureBuilder(
          future: _getFriends(),
          builder: (context, AsyncSnapshot<List<UserObj>?> snapshot) {
            if (snapshot.hasData) {
              if (widget.friends.length == 0) {
                return Center(child: Text("You have no friends added in this class"));
              }
              return Padding(padding: EdgeInsets.symmetric(vertical: 20, horizontal: MediaQuery.of(context).size.width * 0.25),
                child: ListView.separated(
                    itemBuilder: (context, index) => PersonCard(person: widget.friends[index]),
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 10);
                    },
                    itemCount: widget.friends.length),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        )

      ],),
    );
  }

  Future<List<UserObj>?> _getPeers() async { // collection classes holds docs of class id with arr students
    if (!peerCheck) {
      DocumentSnapshot snapshot = await widget.db.collection("classes").doc(widget.classID).get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        for(int i = 0; i < data["students"].length; ++i) {
          peers.add((await widget.db.collection("users")
              .withConverter(fromFirestore: UserObj.fromFirestore, toFirestore: (UserObj userObj, _) => userObj.toFirestore())
              .doc(data["students"][i]).get()).data()!);
        }
      }
      peerCheck = true;
      return peers;
    } else {
      return peers;
    }
  }

  Future<List<UserObj>?> _getFriends() async { // subcollection friends has doc arr holding array called friends
    if (!friendCheck) {
      QuerySnapshot snapshot = await widget.db.collection("users/" + widget.user.email! + "/friends").limit(1).get();
      if (snapshot.size == 0) { // no friends
        friendCheck = true;
        return widget.friends;
      }

      DocumentSnapshot friends_snapshot = await widget.db.collection("users/" + widget.user.email! + "/friends").doc("arr").get();
      final data = friends_snapshot.data() as Map<String, dynamic>;

      for(int i = 0; i < data["friends"].length; ++i) {
        final temp_friend = (await widget.db.collection("users")
            .withConverter(fromFirestore: UserObj.fromFirestore, toFirestore: (UserObj userObj, _) => userObj.toFirestore())
            .doc(data["friends"][i]).get()).data()!;
        if (temp_friend.classes != null && temp_friend.classes!.contains(widget.classID)) {
          widget.friends.add(temp_friend);
        }
      }

      friendCheck = true;
      return widget.friends;
    } else {
      return widget.friends;
    }
  }

  Widget _addFriendCard(UserObj person) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [
      Expanded(child: PersonCard(person: person)),
      Container(margin: EdgeInsets.only(left: 10),
        child: ElevatedButton(
            onPressed: () { // alert user whether or not class was added/class is already present
              for (var temp_person in widget.friends) {
                if (temp_person.email == person.email) {
                  showDialog(context: context, builder: (BuildContext context) => AlertDialog(
                    title: Text("Peer Alert"),
                    content: Text("This person is already present in your friend list"),
                    actions: [TextButton(onPressed: () => Navigator.pop(context, 'OK'), child: Text("OK"))],
                  ));
                  return;
                }
              }
              widget.friends.add(person);
            },
            child: Icon(Icons.person_add)),
      )
    ],);
  }

}

class PersonCard extends StatefulWidget {
  final UserObj person;
  
  PersonCard({Key? key, required this.person}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(

      ),
      child: Material(
          child: InkWell(
            onTap: () {}, // go to profile page
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween ,children: [
                  Text(
                      widget.person.name!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                  Expanded(child: Container())

                ],),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(
                      "Majors: " + (widget.person.majors == null ? "Not set" : widget.person.majors!.join(", ")),
                      style: const TextStyle(fontSize: 14.0)),

                  Expanded(child: Container())
                ],),
              ],
            ),
          )
      ),
    );
  }
  
}
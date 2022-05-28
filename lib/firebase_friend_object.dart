class FriendObj {
  final String? classID;
  final String? email;

  FriendObj({
    this.classID,
    this.email
  });

  factory FriendObj.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return FriendObj(
      classID: data?['classID'],
      email: data?['email']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "classID": classID,
      "email": email
    };
  }
}
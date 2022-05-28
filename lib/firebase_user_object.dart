class UserObj {
  final String? name;
  final String? email;
  final String? bio;
  final List<String>? majors;
  final List<String>? hobbies;
  final List<String>? classes; // list of class ids
  final Map<String, String>? socials; // maps social media website (insta, FB, and SC) to their profile links
  // Friends will be stored in firebase subcollection with friend objects showing which class friend is from

  UserObj({
    this.name,
    this.email,
    this.bio,
    this.majors,
    this.hobbies,
    this.classes,
    this.socials
  });

  factory UserObj.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return UserObj(
      name: data?['name'],
      email: data?['email'],
      bio: data?['bio'],
      majors: data?['majors'] is Iterable ? List.from(data?['majors']) : null,
      hobbies: data?['hobbies'] is Iterable ? List.from(data?['hobbies']) : null,
      classes: data?['classes'] is Iterable ? List.from(data?['classes']) : null,
      socials: data?['socials'] is Iterable ? Map<String, String>.from(data?['socials']) : null
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "email": email,
      "bio": bio,
      "majors": majors,
      "hobbies": hobbies,
      "classes": classes,
      "socials": socials
    };
  }
}
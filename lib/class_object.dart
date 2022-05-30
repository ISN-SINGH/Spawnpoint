class ClassObj {
  final String? id;
  final String? code;
  final String? title;
  final String? level;
  final String? subject;
  final double? minUnits;
  final double? maxUnits;
  final String? description;
  final List<String>? attributes;
  final List<String>? instructors;
  final List<String>? sections;
  final int? capacity;
  final int? seatsAvailable;

  ClassObj({
    this.id,
    this.code,
    this.title,
    this.level,
    this.subject,
    this.minUnits,
    this.maxUnits,
    this.description,
    this.attributes,
    this.instructors,
    this.sections,
    this.capacity,
    this.seatsAvailable
  });

  factory ClassObj.fromJson(Map<String, dynamic> json) {
    return ClassObj(
      id: json['id'],
      code: json['code'],
      title: json['title'],
      level: json['level'],
      subject: json['subject'],
      minUnits: json['minUnits'],
      maxUnits: json['maxUnits'],
      description: json['description'],
      attributes: List.from(json['attributes']),
      instructors: List<String>.from(json['instructors']).isEmpty ?
        List<String>.from(["Not listed"]) :
        List<String>.from(json['instructors']),
      sections: List.from(json['sections']),
      capacity: json['capacity'],
      seatsAvailable: json['seatsAvailable']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['title'] = title;
    data['level'] = level;
    data['subject'] = subject;
    data['minUnits'] = minUnits;
    data['maxUnits'] = maxUnits;
    data['description'] = description;
    data['attributes'] = attributes;
    data['instructors'] = instructors;
    data['sections'] = sections;
    data['capacity'] = capacity;
    data['seatsAvailable'] = seatsAvailable;
    return data;
  }
}
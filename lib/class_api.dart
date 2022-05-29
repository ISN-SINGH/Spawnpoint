import 'dart:convert';
import 'dart:io';

import 'package:testing/class_object.dart';
import 'package:http/http.dart';

// Add functionality for multiple terms in the future
// Get classes based on user query
Future<List<ClassObj>> classList(String query) async {
  String baseUrl = "api.schedgo.com";
  String endpoint = "v3/colleges/ucdavis/terms/202203/courses?query=";
  final split = query.split(" ");
  for (int i = 0; i < split.length; ++i) {
    endpoint = endpoint + split[i];
    if (i != split.length - 1) {
      endpoint = endpoint + "%20";
    }
  }
  endpoint = endpoint + "&limit=10";

  var uri = Uri.http(baseUrl, endpoint);
  Response response = await get(uri);
  List<dynamic> list = jsonDecode(response.body); //JSON string into map
  List<ClassObj> classObjs = list
    .map((e) => ClassObj.fromJson(e))
    .toList();
  return classObjs;
}

Future<List<ClassObj>> classListByIDs(List<String> IDs) async {
  List<ClassObj> classList = List<ClassObj>.empty(growable: true);
  String baseUrl = "api.schedgo.com";
  Map<String, dynamic>? parameters;

  for (int i = 0; i < IDs.length; ++i) {
    String endpoint = "v3/colleges/ucdavis/terms/202203/courses/" + IDs[i];
    print(endpoint); // TODO remove

    var uri = Uri.https(baseUrl, endpoint, parameters);
    Response response = await get(uri);
    dynamic jsonObj = jsonDecode(response.body); //JSON string into map

    List<dynamic> objSections = List<dynamic>.from(jsonObj['sections']);
    List<String> parsedSections = List<String>.empty(growable: true);
    Set<String> parsedInstructors = {};
    for (int j = 0; j < objSections.length; ++j) { // get section id from every section
      parsedSections.add(objSections[i]['id']);
      for (int k = 0; k < objSections[i]['instructors'].length; ++k) { // add all instructors from all sections no repeats
        parsedInstructors.add(objSections[i]['instructors'][k]);
      }
    }

    ClassObj classObj = ClassObj(
      id: jsonObj['id'],
      code: jsonObj['code'],
      title: jsonObj['title'],
      level: jsonObj['level'],
      subject: jsonObj['subject'],
      minUnits: jsonObj['minUnits'],
      maxUnits: jsonObj['maxUnits'],
      description: jsonObj['description'],
      attributes: List<String>.from(jsonObj['attributes']),
      instructors: List<String>.from(parsedInstructors),
      sections: parsedSections
    );

    classList.add(classObj);
  }
  return classList;
}
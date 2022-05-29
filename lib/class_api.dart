import 'dart:convert';

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
    String endpoint = "v3/colleges/ucdavis/terms/202203/courses?query=" + IDs[i] + "&limit=1";

    var uri = Uri.https(baseUrl, endpoint, parameters);
    Response response = await get(uri);
    print(response.body.length); //TODO remove
    List<dynamic> list = jsonDecode(response.body); //JSON string into map
    List<ClassObj> classObj = list
        .map((e) => ClassObj.fromJson(e))
        .toList();
    classList.add(classObj.first);

    //TODO remove
    print("hello");
    print(classObj.first.instructors);
  }
  return classList;
}
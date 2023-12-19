import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

JsonEncoder encorder = new JsonEncoder.withIndent(' ');

/// Class of functions to help push to Firebase
class Database {
  /// Updates Firebase database at [children] with   "[location] : [data]"
  static Future<void> update(
      {required String children,
      required String location,
      dynamic data}) async {
    await FirebaseDatabase.instanceFor(
            app: Firebase.app(), databaseURL: 'DATABASE URL HERE')
        .ref()
        .child(children)
        .update({location: data});
  }

  /// Pushes [data] to Firebase at [children]
  static Future<void> push({required String children, dynamic data}) async {
    await FirebaseDatabase.instanceFor(
            app: Firebase.app(), databaseURL: 'DATABASE URL HERE')
        .ref()
        .child(children)
        .push()
        .set(data);
  }

  static Future<dynamic> once(String child) async{
    List<String> children = child.split('/');
    dynamic jsonData = jsonDecode(await rootBundle.loadString('${children[0]}.json'));
    if(child.length == 2){
      return jsonData[children[1]];
    }
    else if(child.length == 3){
      return jsonData[children[1]][children[2]];
    }
    else if(child.length == 4){
      return jsonData[children[1]][children[2]][children[3]];
    }
    else{
      return jsonData;
    }
  }

  /// Fires when data at [children] is updated
  static Stream<DatabaseEvent> onValue(String children) {
    return FirebaseDatabase.instanceFor(
            app: Firebase.app(), databaseURL: 'DATABASE URL HERE')
        .ref(children)
        .onValue;
  }

  /// Gets the reference for the database at [child]
  static DatabaseReference reference(String child) {
    return FirebaseDatabase.instanceFor(
            app: Firebase.app(), databaseURL: 'DATABASE URL HERE')
        .ref()
        .child(child);
  }
}

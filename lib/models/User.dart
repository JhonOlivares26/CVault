import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String id;
  String name="";
  String email="";
  String? photo;

  User({required this.id, required this.name, required this.email, this.photo});

  factory User.fromFirestore(DocumentSnapshot userDoc) {
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    return User(
      id: userDoc.id,
      name: userData['name'],
      photo: userData['photo'],
      email: userData['email'],
    );
  }

  void setFromFireStore(DocumentSnapshot userDoc) {
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    id = userDoc.id;
    name = userData['name'];
    photo = userData['photo'];
    email = userData['email'];
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photo': photo,
    };
  }
}
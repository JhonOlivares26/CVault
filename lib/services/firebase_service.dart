import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cvault/models/user.dart' as cv_user;


class FirebaseService {
  static Future<auth.User?> signInWithEmailPassword(String email, String password) async {
    try {
      auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      auth.User? user = userCredential.user;
      if (user != null) {
        CollectionReference users = FirebaseFirestore.instance.collection('users');
        DocumentSnapshot docSnapshot = await users.doc(user.uid).get();
        if (docSnapshot.exists) {
          Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
          cv_user.User customUser = cv_user.User(
            id: user.uid, 
            name: user.displayName ?? 'Nombre no proporcionado', 
            email: user.email!, 
            photo: user.photoURL ?? 'URL de la foto no proporcionada',
            userType: data['userType'] ?? 'Tipo de usuario no proporcionado'
          );
          users.doc(customUser.id).set(customUser.toJson());
        }
      }
      return user;
    } on auth.FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  static Future<auth.User?> signInGoogle() async {
    GoogleSignIn signIn = GoogleSignIn(scopes: ['email']);

    GoogleSignInAccount? googleSignInAccount = await signIn.signIn();
    if (googleSignInAccount != null) {
      GoogleSignInAuthentication authentication =
          await googleSignInAccount.authentication;

      auth.OAuthCredential credential = auth.GoogleAuthProvider.credential(
          accessToken: authentication.accessToken,
          idToken: authentication.idToken);

      auth.UserCredential userCredential =
          await auth.FirebaseAuth.instance.signInWithCredential(credential);

      auth.User? user = userCredential.user;
      if (user != null) {
        CollectionReference users = FirebaseFirestore.instance.collection('users');
        DocumentSnapshot docSnapshot = await users.doc(user.uid).get();
        if (docSnapshot.exists) {
          Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
          cv_user.User customUser = cv_user.User(
            id: user.uid, 
            name: user.displayName ?? 'Nombre no proporcionado', 
            email: user.email!, 
            photo: user.photoURL ?? 'URL de la foto no proporcionada',
            userType: data['userType'] ?? 'Tipo de usuario no proporcionado'
          );
          users.doc(customUser.id).set(customUser.toJson());
        }
      }
      return user;
    }
  }

  static Future<String?> registerWithEmailPassword(String email, String password, String name, String userType) async {
    try {
      auth.UserCredential userCredential = await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      auth.User? user = userCredential.user;
      if (user != null) {
        CollectionReference users = FirebaseFirestore.instance.collection('users');
        users.doc(user.uid).set({
          'name': name,
          'email': email,
          'userType': userType, // Agrega el tipo de usuario al documento
        });
        return 'Registro exitoso';
      }
      return null;
    } on auth.FirebaseAuthException catch (e) {
      print(e.message);
      return e.message;
    }
  }
}
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cvault/models/user.dart' as cv_user;

class FirebaseService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<auth.User?> signInWithEmailPassword(
      String email, String password) async {
    try {
      auth.UserCredential userCredential =
          await auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      auth.User? user = userCredential.user;
      if (user != null) {
        CollectionReference users =
            FirebaseFirestore.instance.collection('users');
        DocumentSnapshot docSnapshot = await users.doc(user.uid).get();
        if (docSnapshot.exists) {
          print("El usuario ya existe en Firestore");
        } else {
          cv_user.User customUser = cv_user.User(
            id: user.uid,
            name: user.displayName ?? 'Nombre no proporcionado',
            email: user.email!,
            photo: user.photoURL ?? 'URL de la foto no proporcionada',
            userType: 'Tipo de usuario no proporcionado',
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
        cv_user.User customUser = cv_user.User(
            id: user.uid,
            name: user.displayName ?? 'Nombre no proporcionado',
            email: user.email!,
            photo: user.photoURL ?? 'URL de la foto no proporcionada',
            userType: 'normal');
        CollectionReference users =
            FirebaseFirestore.instance.collection('users');
        DocumentSnapshot docSnapshot = await users.doc(customUser.id).get();
        if (!docSnapshot.exists) {
          users.doc(customUser.id).set(customUser.toJson());
        }
      }
      return user;
    }
  }

  static Future<String?> registerWithEmailPassword(
      String email, String password, String name, String userType) async {
    try {
      auth.UserCredential userCredential =
          await auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      auth.User? user = userCredential.user;
      if (user != null) {
        // Actualizar la información del perfil del usuario
        await user.updatePhotoURL(
            'https://firebasestorage.googleapis.com/v0/b/cvault-d4348.appspot.com/o/postsImages%2FUserPorDefecto.webp?alt=media&token=d0f99bd3-cc98-47f7-9888-31a767a46883'); // URL de la imagen por defecto
        await user.updateDisplayName(name);

        // Recargar la información del usuario para obtener la URL de la foto de perfil actualizada
        await user.reload();
        user = auth.FirebaseAuth.instance.currentUser;

        CollectionReference users =
            FirebaseFirestore.instance.collection('users');
        users.doc(user!.uid).set({
          'name': name,
          'email': email,
          'userType': userType, // Agrega el tipo de usuario al documento
          'photo': user.photoURL,
        });
        return 'Registro exitoso';
      }
      return null;
    } on auth.FirebaseAuthException catch (e) {
      print(e.message);
      return e.message;
    }
  }

  Future<void> deleteAccount(String userId) async {
    // Elimina el usuario de la colección 'users'
    await _firestore.collection('users').doc(userId).delete();
    // Elimina el usuario de Firebase Auth
    auth.User? user = _auth.currentUser;
    await user?.delete();
  }
}

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cvault/models/User.dart'; // Importa tu modelo de usuario

class UserService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Escucha los cambios en el estado de autenticación del usuario
  Stream<User?> get user {
    return _auth.authStateChanges().asyncMap((auth.User? user) async {
      if (user != null) {
        return await getUser(user.uid);
      } else {
        return null;
      }
    });
  }

  Future<User?> getCurrentUser() async {
    final auth.User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser.uid).get();
      return User.fromFirestore(doc);
    }
    return null;
  }

  Future<User> getUser(String? id) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(id).get();
    return User.fromFirestore(doc);
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cvault/models/User.dart'; // Importa tu modelo de usuario

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User> getUser(String? id) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(id).get();

    return User.fromFirestore(doc);
  }
}
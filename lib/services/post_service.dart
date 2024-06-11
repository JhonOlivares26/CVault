import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cvault/models/Post.dart'; // Asegúrate de reemplazar 'your_project' con el nombre de tu proyecto
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';


class PostService {
  final CollectionReference _postCollection = FirebaseFirestore.instance.collection('posts');

Future<String> createPost(Post post, File imageFile) async {
    DocumentReference docRef;
    // Verifica si el post ya tiene un id
    if (post.id.isEmpty) {
      docRef = _postCollection.doc();
      post.id = docRef.id; // Asigna el ID generado a tu post
    } else {
      docRef = _postCollection.doc(post.id);
    }
    final ref = FirebaseStorage.instance.ref().child('postsImages/${docRef.id}');
    try {
      final task = ref.putFile(imageFile);
      final imageUrl = await (await task).ref.getDownloadURL();
      post.imageUrl = imageUrl;

    } catch (e) {

      print('Error al subir archivo: $e');
    }

    await docRef.set(post.toJson());
    return docRef.id;
  }

  Future<Post> getPostById(String postId) async {
    DocumentSnapshot postDoc = await _postCollection.doc(postId).get();
    return Post.fromFirestore(postDoc);
  }

  Future<List<Post>> getPostsByUser(String userId) async {
    QuerySnapshot querySnapshot = await _postCollection.where('userId', isEqualTo: userId).get();
    return querySnapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }

  Future<void> updatePost(Post post) async {
    await _postCollection.doc(post.id).update(post.toJson());
  }

  Future<String> getUserName(String userId) async {
  try {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userSnapshot.exists) {
      // Si el documento del usuario existe, devuelve el nombre del usuario
      return userSnapshot['name'];
    } else {
      // Si el documento del usuario no existe, devuelve un valor predeterminado o una cadena vacía
      return 'Usuario desconocido';
    }
  } catch (e) {
    // Manejar cualquier error que pueda ocurrir durante la recuperación del nombre del usuario
    print('Error al obtener el nombre del usuario: $e');
    return 'Usuario desconocido';
  }
}
  
Future<String> getUserPhoto(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        // Si el documento del usuario existe, devuelve el enlace de la foto de perfil del usuario
        return userSnapshot['photo'];
      } else {
        // Si el documento del usuario no existe, devuelve un valor predeterminado o una cadena vacía
        return ''; // O puedes devolver un valor predeterminado para la foto de perfil
      }
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la recuperación del enlace de la foto de perfil del usuario
      print('Error al obtener la foto de perfil del usuario: $e');
      return ''; // O puedes devolver un valor predeterminado para la foto de perfil
    }
  }

  Future<void> deletePost(String postId) async {
    await _postCollection.doc(postId).delete();
  }
}
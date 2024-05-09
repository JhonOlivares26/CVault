import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cvault/models/post.dart'; // Asegúrate de reemplazar 'your_project' con el nombre de tu proyecto

class PostService {
  final CollectionReference _postCollection = FirebaseFirestore.instance.collection('posts');

Future<String> createPost(Post post) async {
  DocumentReference docRef;
  // Verifica si el post ya tiene un id
  if (post.id.isEmpty) {
    // Si el id está vacío, genera un nuevo id
    docRef = _postCollection.doc();
    post.id = docRef.id; // Asigna el ID generado a tu post
  } else {
    // Si el id ya está establecido, úsalo
    docRef = _postCollection.doc(post.id);
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

  Future<void> deletePost(String postId) async {
    await _postCollection.doc(postId).delete();
  }
}
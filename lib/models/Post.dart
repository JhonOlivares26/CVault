import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Post with ChangeNotifier {
  String id;
  String title;
  String userId;
  String description;
  String? imageUrl; // nuevo campo para la imagen
  int likes; // nuevo campo para los "me gustas"
  
  DateTime timestamp;

  Post({required this.id, required this.title, required this.userId, required this.description, this.imageUrl, required this.likes, required this.timestamp});

  factory Post.fromFirestore(DocumentSnapshot postDoc) {
    Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
    return Post(
      id: postDoc.id,
      userId: postData['userId'],
      title: postData['title'], 
      description: postData['description'], // Cambia 'content' a 'description'
      imageUrl: postData['imageUrl'], // nuevo campo para la imagen
      likes: postData['likes'], // nuevo campo para los "me gustas"
      timestamp: (postData['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Incluye el id del post
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl, // nuevo campo para la imagen
      'likes': likes, // nuevo campo para los "me gustas"
      'timestamp': timestamp,
    };
  }

  void updateContent(String newContent) {
    description = newContent;
    notifyListeners();
  }

  void updateLikes(int newLikes) { // nuevo método para actualizar los "me gustas"
    likes = newLikes;
    notifyListeners();
  }
}
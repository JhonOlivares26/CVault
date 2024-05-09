import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cvault/models/Post.dart'; // Reemplaza 'tu_paquete' con el nombre de tu paquete

class UserPostsScreen extends StatefulWidget {
  @override
  _UserPostsScreenState createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen> {
  final _postCollection = FirebaseFirestore.instance.collection('posts');
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Posts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _postCollection.where('userId', isEqualTo: _userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              final post = Post.fromFirestore(snapshot.data!.docs[index]);
              return ListTile(
                title: Text(post.title),
                subtitle: Text(post.description),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Aquí puedes manejar la eliminación del post
                  },
                ),
                onTap: () {
                  // Aquí puedes manejar la edición del post
                },
              );
            },
          );
        },
      ),
    );
  }
}
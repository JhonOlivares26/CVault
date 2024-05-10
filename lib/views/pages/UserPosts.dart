import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cvault/models/Post.dart';
import 'package:cvault/services/post_service.dart';
import 'package:cvault/widgets/Confirmation.dart';

class UserPostsScreen extends StatefulWidget {
  @override
  _UserPostsScreenState createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen> {
  final _postCollection = FirebaseFirestore.instance.collection('posts');
  final _userId = FirebaseAuth.instance.currentUser?.uid;
  final _postService = PostService();

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

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Número de columnas
              childAspectRatio: 0.54, // Relación de aspecto de cada tarjeta
            ),
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              final post = Post.fromFirestore(snapshot.data!.docs[index]);
              return Card(
                child: Column(
                  children: <Widget>[
                    if (post.imageUrl != null) 
                      AspectRatio(
                        aspectRatio: 1, // Para mantener la imagen cuadrada
                        child: Image.network(post.imageUrl!),
                      ),
                    ListTile(
                      title: Text(post.title),
                      subtitle: Text(post.description),
                    ),
                    Text('Likes: ${post.likes}'), // Muestra el número de likes
                    ButtonBar(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Aquí puedes manejar la edición del post
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ConfirmationDialog(
                                  title: 'Confirmar eliminación',
                                  content: '¿Estás seguro de que quieres eliminar este post?',
                                  onConfirm: () {
                                    _postService.deletePost(post.id); // Elimina el post
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
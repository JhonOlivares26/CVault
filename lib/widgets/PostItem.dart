import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cvault/views/pages/PostDetails.dart';
import 'package:cvault/services/post_service.dart'; // Importa el servicio PostService
import 'package:firebase_auth/firebase_auth.dart';

class PostItem extends StatefulWidget {
  final DocumentSnapshot post;

  PostItem({required this.post});

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool isLiked = false;
  final PostService _postService = PostService(); // Instancia del servicio PostService

@override
Widget build(BuildContext context) {
  Map<String, dynamic> data = widget.post.data() as Map<String, dynamic>;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetails(
            userId: data['userId'],
            title: data['title'],
            imageUrl: data['imageUrl'],
            description: data['description'],
            likes: data['likes'],
          ),
        ),
      );
    },
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 100,
              child: Image.network(data['imageUrl'], fit: BoxFit.cover),
            ),
            const SizedBox(width: 1.0),  
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 1.0),
                  Text(
                    data['description'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1.0),
                  Text(
                    DateFormat('dd/MM/yyyy').format((data['timestamp'] as Timestamp).toDate()),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5.0),
                  FutureBuilder<String>(
                    future: _postService.getUserName(data['userId']), // Llama al método _getUserName del servicio PostService
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Muestra un indicador de carga mientras se obtiene el nombre del usuario
                      } else if (snapshot.hasError) {
                        return Text('Error al obtener el nombre del usuario'); // Muestra un mensaje de error si hay algún problema al obtener el nombre del usuario
                      } else {
                        return Text(
                          'Publicado por: ${snapshot.data}',
                          style: const TextStyle(color: Colors.grey),
                        ); // Muestra el nombre del usuario obtenido del servicio
                      }
                    },
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                // Obtiene el ID del usuario actual
                final userId = FirebaseAuth.instance.currentUser?.uid;

                // Carga los datos del post
                DocumentSnapshot doc = await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).get();
                Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

                // Comprueba si el usuario ha dado 'like' al post
                isLiked = (data?['userLikes'] as List?)?.contains(userId) ?? false;

                if (data != null) {
                  if (data['userLikes'] == null) {
                    data['userLikes'] = [];
                  }

                  // Cambia el estado de 'like' del usuario
                  setState(() {
                    isLiked = !isLiked;
                  });

                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.post.id)
                      .update({
                    'likes': FieldValue.increment(isLiked ? 1 : -1),
                    'userLikes': isLiked ? FieldValue.arrayUnion([userId]) : FieldValue.arrayRemove([userId]),
                  });
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(
                    Icons.favorite,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${data?['likes']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ), // Aquí estaba mal ubicado el cierre de paréntesis
          ],
        ),
      ),
    ),
  );
}}
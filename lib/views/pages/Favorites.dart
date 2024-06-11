import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('userLikes', arrayContains: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (context, index) {
              DocumentSnapshot post = snapshot.data!.docs[index];
              Map<String, dynamic> data = post.data() as Map<String, dynamic>;

              return ListTile(
                leading: Image.network(data['imageUrl']),
                title: Text(data['title']),
                subtitle: Text((data['timestamp'] as Timestamp).toDate().toString()),
                trailing: IconButton(
                  icon: Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(post.id)
                        .update({
                      'likes': FieldValue.increment(-1),
                      'userLikes': FieldValue.arrayRemove([userId]),
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
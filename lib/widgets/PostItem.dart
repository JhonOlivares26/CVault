import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PostItem extends StatefulWidget {
  final DocumentSnapshot post;

  PostItem({required this.post});

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = widget.post.data() as Map<String, dynamic>;
    String docId = widget.post.id;

    return ListTile(
      leading: Image.network(data['imageUrl']),
      title: Text(data['title']),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(data['description']),
          Text('${DateFormat('dd/MM/yyyy').format((data['timestamp'] as Timestamp).toDate())}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              // Actualiza el estado
              setState(() {
                isLiked = !isLiked;
              });

              // Actualiza Firestore
              await FirebaseFirestore.instance.collection('posts').doc(docId).update({
                'likes': FieldValue.increment(isLiked ? 1 : -1),
              });
            },
            child: Icon(
              Icons.favorite,
              color: isLiked ? Colors.red : Colors.grey,
            ),
          ),
          Text('${data['likes']}'),
        ],
      ),
    );
  }
}
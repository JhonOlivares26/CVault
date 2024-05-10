import 'package:flutter/material.dart';
import 'package:cvault/models/Post.dart';
import 'package:cvault/services/post_service.dart';

class EditPostForm extends StatefulWidget {
  final Post post;

  EditPostForm({required this.post});

  @override
  _EditPostFormState createState() => _EditPostFormState();
}

class _EditPostFormState extends State<EditPostForm> {
  final _formKey = GlobalKey<FormState>();
  final _postService = PostService();
  late String _title;
  late String _description;

  @override
  void initState() {
    super.initState();
    _title = widget.post.title;
    _description = widget.post.description;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: _title,
            decoration: InputDecoration(labelText: 'Título'),
            onSaved: (value) {
              _title = value!;
            },
          ),
          TextFormField(
            initialValue: _description,
            decoration: InputDecoration(labelText: 'Descripción'),
            onSaved: (value) {
              _description = value!;
            },
          ),
          ElevatedButton(
            child: Text('Guardar'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Post updatedPost = Post(
                  id: widget.post.id,
                  title: _title,
                  description: _description,
                  userId: widget.post.userId, // Copia userId del post original
                  likes: widget.post.likes, // Copia likes del post original
                  timestamp: widget.post.timestamp, // Copia timestamp del post original
                  imageUrl: widget.post.imageUrl, // Copia imageUrl del post original si existe
                );
                _postService.updatePost(updatedPost);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
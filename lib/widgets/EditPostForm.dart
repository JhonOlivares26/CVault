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
                  userId: widget.post.userId,
                  likes: widget.post.likes,
                  timestamp: widget.post.timestamp,
                  imageUrl: widget.post.imageUrl,
                );
                _postService.updatePost(updatedPost);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmación'),
                      content: const Text('El post ha sido actualizado exitosamente.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
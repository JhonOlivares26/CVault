import 'package:flutter/material.dart';
import 'package:cvault/models/post.dart';
import 'package:cvault/services/post_service.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _postService = PostService();

  String _title = '';
  String _description = '';
  String _imageUrl = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Aquí debes reemplazar 'userId' y 'timestamp' con los valores reales
      final newPost = Post(
        id: DateTime.now().toString(),
        userId: 'userId',
        title: _title,
        description: _description,
        imageUrl: _imageUrl,
        likes: 0,
        timestamp: DateTime.now(),
      );

      _postService.createPost(newPost);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Post'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Título'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por favor, introduce el título del post';
                }
                return null;
              },
              onSaved: (value) {
                _title = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Descripción'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por favor, introduce el contenido del post';
                }
                return null;
              },
              onSaved: (value) {
                _description = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'URL de la imagen'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por favor, introduce la URL de la imagen';
                }
                return null;
              },
              onSaved: (value) {
                _imageUrl = value!;
              },
            ),
            ElevatedButton(
              child: Text('Crear Post'),
              onPressed: _submitForm,
            ),
          ],
        ),
      ),
    );
  }
}
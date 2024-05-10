import 'package:flutter/material.dart';
import 'package:cvault/models/Post.dart';
import 'package:cvault/services/post_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _postService = PostService();
  final _picker = ImagePicker();

  String _title = '';
  String _description = '';
  XFile? _image;

void _submitForm() async { // Agrega async aquí
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    // Obtiene el userId del usuario actual
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      final newPost = Post(
        id: '', // Deja el id vacío por ahora
        userId: userId, // Usa el userId obtenido
        title: _title,
        description: _description,
        imageUrl: '', // Deja imageUrl vacío por ahora
        likes: 0,
        timestamp: DateTime.now(),
      );

      if (_image != null) {
        // Crea el post y obtiene el id generado por Firebase
        final postId = await _postService.createPost(newPost, File(_image!.path)); // Agrega await aquí
        // Actualiza el id del post
        newPost.id = postId;
      } else {
        // Maneja el caso en que no se seleccionó una imagen
        print('No se seleccionó una imagen');
      }
    }
  }
}

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedFile;
    });
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
            TextButton(
              child: Text('Seleccionar imagen'),
              onPressed: _pickImage,
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
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cvault/models/Post.dart';
import 'package:cvault/services/post_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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
  File? _imageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _title = widget.post.title;
    _description = widget.post.description;
    _imageUrl = widget.post.imageUrl; // Obtener la URL de la imagen actual
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrl =
            null; // Eliminar la URL de la imagen actual si se seleccionó una nueva imagen
      });
    }
  }

  Future<void> _savePost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Subir la nueva imagen a Firebase Storage si se seleccionó una
      String? newImageUrl;
      if (_imageFile != null) {
        final firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('postImages')
            .child('${widget.post.id}.jpg');
        await ref.putFile(_imageFile!);
        newImageUrl = await ref.getDownloadURL();
      }

      // Actualizar los datos del post
      Post updatedPost = Post(
        id: widget.post.id,
        title: _title,
        description: _description,
        userId: widget.post.userId,
        likes: widget.post.likes,
        timestamp: widget.post.timestamp,
        imageUrl: newImageUrl ??
            _imageUrl, // Usar la nueva URL si se seleccionó una imagen nueva
      );
      _postService.updatePost(updatedPost);

      // Mostrar un diálogo de confirmación
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
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              initialValue: _title,
              decoration: InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el título';
                }
                return null;
              },
              onSaved: (value) {
                _title = value!;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              initialValue: _description,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la descripción';
                }
                return null;
              },
              onSaved: (value) {
                _description = value!;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Seleccionar Imagen'),
            ),
            if (_imageFile !=
                null) // Mostrar la vista previa de la imagen seleccionada
              SizedBox(
                height: 200,
                child: Image.file(_imageFile!),
              ),
            if (_imageUrl != null) // Mostrar la imagen actual si existe
              SizedBox(
                height: 200,
                child: Image.network(_imageUrl!),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Guardar'),
              onPressed: _savePost,
            ),
          ],
        ),
      ),
    );
  }
}

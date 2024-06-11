import 'package:flutter/material.dart';
import 'package:cvault/models/Post.dart';
import 'package:cvault/services/post_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cvault/views/pages/HomePage.dart';
import 'package:cvault/widgets/Alert.dart';
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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Obtiene el userId del usuario actual
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        final newPost = Post(
          id: '',
          userId: userId, // Usa el userId obtenido
          title: _title,
          description: _description,
          imageUrl: '',
          likes: 0,
          timestamp: DateTime.now(),
        );

        if (_image != null) {
          // Crea el post y obtiene el id generado por Firebase
          final postId = await _postService.createPost(
              newPost, File(_image!.path)); // Agrega await aquí
          // Actualiza el id del post
          newPost.id = postId;
          await showAlert(context, 'Registro exitoso', 'Post creado con éxito');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
          );
        } else {
          await showAlert(context, 'Error', 'Selecciona una imagen');
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

  void _removeImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
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
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.only(
                    top:
                        10.0), // Alinea el texto del labelText en la parte superior
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  maxLines: 5, // Ajusta el número de líneas a mostrar
                  textAlignVertical: TextAlignVertical
                      .top, // Alinea el texto en la parte superior
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
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    child: Text('Seleccionar imagen'),
                    onPressed: _pickImage,
                  ),
                  ElevatedButton(
                    child: Text('Crear Post'),
                    onPressed: _submitForm,
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Mostrar la imagen seleccionada si existe
              if (_image != null)
                Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    Container(
                      width: MediaQuery.of(context)
                          .size
                          .width, // Ancho de la pantalla
                      height: 200,
                      child: Image.file(
                        File(_image!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(
                            0.5), // Color del fondo (negro con transparencia)
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close,
                            color: Colors.white), // Icono blanco
                        onPressed: _removeImage,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
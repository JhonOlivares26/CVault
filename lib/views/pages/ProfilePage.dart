import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:cvault/services/firebase_service.dart';
import 'package:cvault/widgets/Confirmation.dart';
import 'package:cvault/views/pages/LoginPage.dart';
import 'package:cvault/widgets/Alert.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth.User? user = auth.FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? userType;
  String? photo;
  bool _isLoading = false;

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });

      final firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('userProfile')
          .child('${user!.uid}.jpg');

      await ref.putFile(File(pickedFile.path));

      photo = await ref.getDownloadURL();

      // Actualiza el campo 'photo' en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'photo': photo,
      });

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      // Actualiza solo el campo 'name' en Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'name': name,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Perfil actualizado')));

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          photo = data[
              'photo']; // Asigna el valor de 'photo' a partir de los datos del snapshot

          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            photo != null ? NetworkImage(photo!) : null,
                        child: photo == null
                            ? Icon(Icons.camera_alt, size: 50)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: pickImage,
                        ),
                      ),
                      _isLoading ? CircularProgressIndicator() : Container(),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: data['name'],
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu nombre';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      name = value;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    initialValue: data['email'],
                    decoration: InputDecoration(labelText: 'Email'),
                    enabled: false,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saveProfile,
                    child: Text('Guardar'),
                  ),
                  Spacer(),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () async {
                        bool confirm = await showDialog(
                          context: context,
                          builder: (BuildContext context) => ConfirmationDialog(
                            title: 'Confirmar eliminación',
                            content:
                                '¿Estás seguro de que quieres eliminar tu cuenta?',
                            onConfirm: () async {
                              setState(() {
                                _isLoading = true;
                              });

                              String userId =
                                  auth.FirebaseAuth.instance.currentUser!.uid;
                              await FirebaseService().deleteAccount(userId);

                              setState(() {
                                _isLoading = false;
                              });

                              await showAlert(
                                context,
                                'Cuenta eliminada con éxito',
                                'No te olvidaremos',
                              );
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            },
                          ),
                        );

                        // Para evitar un error si el usuario cierra el diálogo sin confirmar
                        if (confirm == null) {
                          return;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

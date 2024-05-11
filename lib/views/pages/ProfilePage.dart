import 'dart:io';
import 'dart:math';
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

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('userProfile')
          .child('${user!.uid}.jpg');

      await ref.putFile(File(pickedFile.path));

      photo = await ref.getDownloadURL();

      // Actualiza el campo 'photo' en Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'photo': photo,
      });

      setState(() {}); // Actualiza la UI
    }
  }

  Future<void> saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Actualiza solo el campo 'name' en Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'name': name,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Perfil actualizado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Cargando...');
          }

          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          photo = data['photo']; // Asigna el valor de 'photo' a partir de los datos del snapshot

          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: photo != null ? NetworkImage(photo!) : null,
                    child: photo == null ? Icon(Icons.camera_alt, size: 50) : null,
                  ),
                ),
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
                TextFormField(
                  initialValue: data['email'],
                  decoration: InputDecoration(labelText: 'Email'),
                  enabled: false, // Deshabilita el campo de email para que no se pueda modificar
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: saveProfile,
                  child: Text('Guardar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) => ConfirmationDialog(
                        title: 'Confirmar eliminación',
                        content: '¿Estás seguro de que quieres eliminar tu cuenta?',
                        onConfirm: () async {

                          String userId = auth.FirebaseAuth.instance.currentUser!.uid; // Obtén el ID del usuario actual
                          await FirebaseService().deleteAccount(userId); // Pasa el ID del usuario a deleteAccount
                        },
                      ),
                    );
                    await showAlert(context, 'Cuenta eliminada con éxito', 'no te extrañaremos');
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Color de fondo del botón
                  ),
                  child: const Text( 'Eliminar cuenta', style: TextStyle(color: Colors.white)), // Color del texto del botón
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
import 'dart:io';
import 'dart:typed_data';
import 'package:cvault/services/firebase_service.dart';
import 'package:cvault/widgets/Alert.dart';
import 'package:cvault/widgets/Confirmation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

import 'LoginPage.dart';

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
  String? userPdf;
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

  Future<void> downloadAndOpenPdf(String pdfUrl) async {
    final response = await http.get(Uri.parse(pdfUrl));

    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;

      final File file = File('$tempPath/profile.pdf');

      await file.writeAsBytes(bytes);

      OpenFile.open(file.path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar el PDF'),
        ),
      );
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

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text('Usuario no encontrado');
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          photo = data['photo'];
          userPdf = data['userPdf'];

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
                  SizedBox(height: 10),
                  if (userPdf != null)
                    ElevatedButton(
                      onPressed: () async {
                        if (userPdf != null) {
                          await downloadAndOpenPdf(userPdf!);
                        }
                      },
                      child: Text('Ver PDF'),
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
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) => ConfirmationDialog(
                            title: 'Confirmar eliminación',
                            content:
                                '¿Estás seguro de que quieres eliminar tu cuenta?',
                            onConfirm: () async {
                              String userId =
                                  auth.FirebaseAuth.instance.currentUser!.uid;
                              await FirebaseService().deleteAccount(userId);
                            },
                          ),
                        );
                        await showAlert(context, 'Cuenta eliminada con éxito',
                            'No te extrañaremos');
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (Route<dynamic> route) => false);
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

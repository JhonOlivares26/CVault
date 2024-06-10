import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:file_picker/file_picker.dart';
import 'package:cvault/services/firebase_service.dart';
import 'package:cvault/views/pages/LoginPage.dart';
import 'package:cvault/widgets/Alert.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _email = '';
  String _skills = '';
  String _password = '';
  String _confirmPassword = '';
  String _userType = 'Persona';
  String? _selectedPdf;

  Future<String?> uploadPDF(File pdfFile) async {
    try {
      String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + '.pdf';
      storage.Reference ref =
          storage.FirebaseStorage.instance.ref().child('pdfs').child(fileName);

      // Configurar el tipo de contenido del PDF
      final metadata = storage.SettableMetadata(
        contentType: 'application/pdf',
      );

      // Subir el archivo con el tipo de contenido especificado
      await ref.putFile(pdfFile, metadata);

      // Obtener la URL de descarga del PDF
      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error al subir el archivo PDF: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
        backgroundColor: Colors.blue.withOpacity(0.5),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.withOpacity(0.5),
                  Colors.white,
                  Colors.blue.withOpacity(0.5),
                ],
                stops: [0.1, 0.5, 0.9],
                transform: GradientRotation(0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'CVault',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nombre *',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'El nombre es requerido' : null,
                          onSaved: (value) => _firstName = value!,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Correo *',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'El correo es requerido' : null,
                          onSaved: (value) => _email = value!,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Contraseña *',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value!.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _password = value;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Confirmar Contraseña *',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value != _password) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                          onSaved: (value) => _confirmPassword = value!,
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf']);
                            if (result != null) {
                              setState(() {
                                _selectedPdf = result.files.single.path!;
                              });
                            }
                          },
                          child: Text('Hoja de vida'),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _userType,
                              hint: Text(
                                'Selecciona el tipo de usuario',
                                textAlign: TextAlign.center,
                              ),
                              items: <String>[
                                'Persona',
                                'Empresa'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _userType = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          child: Text('Registrar'),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              String? result;
                              if (_selectedPdf != null) {
                                String? downloadURL =
                                    await uploadPDF(File(_selectedPdf!));

                                result = await FirebaseService
                                    .registerWithEmailPassword(
                                  _email,
                                  _skills,
                                  _password,
                                  _firstName,
                                  _userType,
                                  userPdf: downloadURL,
                                );
                              } else {
                                result = await FirebaseService
                                    .registerWithEmailPassword(
                                  _email,
                                  _skills,
                                  _password,
                                  _firstName,
                                  _userType,
                                );
                              }
                              if (result == 'Registro exitoso') {
                                await showAlert(
                                  context,
                                  'Registro exitoso',
                                  'Usuario registrado con éxito',
                                );
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(),
                                  ),
                                );
                              } else {
                                showAlert(
                                  context,
                                  'Error',
                                  result ?? 'Error desconocido',
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

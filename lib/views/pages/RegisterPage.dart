import 'package:cvault/views/pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cvault/services/firebase_service.dart';
import 'package:cvault/widgets/Alert.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '', _email = '', _password = '', _confirmPassword = '', _userType = 'normal';

  Future<void> registerUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Usuario registrado con éxito: ${userCredential.user!.uid}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('La contraseña proporcionada es demasiado débil.');
      } else if (e.code == 'email-already-in-use') {
        print('La cuenta ya existe para ese correo electrónico.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'El nombre es requerido' : null,
                onSaved: (value) => _firstName = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Correo'),
                validator: (value) => value!.isEmpty ? 'El correo es requerido' : null,
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value!.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
                onChanged: (value) {
                  _password = value; // Guarda _password cuando cambia
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirmar Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value != _password) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
                onSaved: (value) => _confirmPassword = value!,
              ),
              DropdownButton<String>(
                value: _userType,
                hint: Text('Selecciona el tipo de usuario'),
                items: <String>['normal', 'empresa'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _userType = newValue!;
                  });
                },
              ),
              ElevatedButton(
                child: Text('Registrar'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    String? result = await FirebaseService.registerWithEmailPassword(_email, _password, _firstName, _userType);
                    if (result == 'Registro exitoso') {
                      showAlert(context, 'Registro exitoso', 'Usuario registrado con éxito');
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    } else {
                      showAlert(context, 'Error', result ?? 'Error desconocido');
                    }
                  }
                },
              ),
            ],
          ),
          
        ),
      ),
    );
  }
}
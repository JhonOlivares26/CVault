import 'package:flutter/material.dart';
import 'package:cvault/services/firebase_service.dart';
import 'package:cvault/controllers/ValidateTextFormController.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'HomePage.dart';
import 'RegisterPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to CVault'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(20.0), // Agrega un margen alrededor del campo de texto
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0), // Agrega bordes redondeados
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu correo electrónico';
                  }
                  return null;
                },
              ),
            ),
            Container(
              margin: EdgeInsets.all(20.0), // Agrega un margen alrededor del campo de texto
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0), // Agrega bordes redondeados
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  auth.User? user = await FirebaseService.signInWithEmailPassword(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (user != null) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al iniciar sesión')),
                    );
                  }
                }
              },
              child: Text('Iniciar sesión'),

            ),
            ElevatedButton(
              onPressed: () async {
                auth.User? user = await FirebaseService.signInGoogle();
                if (user != null) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al iniciar sesión con Google')),
                  );
                }
              },
              child: const Text('Iniciar sesión con Google'),
            ),

            ElevatedButton(
              onPressed: () async {
                // Navega a RegisterPage cuando se presione este botón
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: const Text('Registrarse'),
            ),

          ],
        ),
      ),
    );
  }
}
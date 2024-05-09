import 'package:flutter/material.dart';
import 'package:cvault/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'HomePage.dart';
import 'RegisterPage.dart';
import 'package:animate_do/animate_do.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to CVault'),
        centerTitle: true,
      ),
      body: LayoutBuilder(  // Agrega LayoutBuilder
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(  // Agrega ConstrainedBox
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Centra los widgets en la Columna
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
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
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',              
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0), // Agrega bordes redondeados
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: _togglePasswordVisibility,
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

                      SizedBox(height: 40,),

                      FadeIn(
                      child: Text('----------------------- Or Login with ------------------------', style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),),
                    ),

                    SizedBox(height: 10,),

                      TextButton(
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
                        child: Image.network('https://developers.google.com/identity/images/g-logo.png', height: 50.0),
                      ),

                      SizedBox(height: 20,),

                      TextButton(
                        onPressed: () async {
                          // Navega a RegisterPage cuando se presione este botón
                          Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                        },
                        //child: const Text("Don't have an account? Sign in now"),
                        child: FadeInUp(duration: Duration(milliseconds: 2000), child: const Text("Don't have an account? Sign in now", style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
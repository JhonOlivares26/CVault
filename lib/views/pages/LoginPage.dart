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
        backgroundColor: Colors.blue.withOpacity(0.5),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Para cerrar el teclado cuando se toca fuera de un campo de texto
        },
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context)
                .size
                .height, // Obtiene la altura total de la pantalla
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 100), // Ajusta la distancia del título
                      Text(
                        'CVault',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu correo electrónico';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
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
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            auth.User? user =
                                await FirebaseService.signInWithEmailPassword(
                              _emailController.text,
                              _passwordController.text,
                            );
                            if (user != null) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Error al iniciar sesión')),
                              );
                            }
                          }
                        },
                        child: Text('Iniciar sesión'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Para la función de recuperar en el futuro
                        },
                        child: Text(
                          'Olvidé mi contraseña',
                          style: TextStyle(
                            color: Colors.black38,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        // Centra el texto "Login with" en la parte inferior
                        child: Text(
                          'Ingresar con',
                          style: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () async {
                          auth.User? user =
                              await FirebaseService.signInGoogle();
                          if (user != null) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error al iniciar sesión con Google')),
                            );
                          }
                        },
                        child: Image.network(
                            'https://imagensemoldes.com.br/wp-content/uploads/2020/04/imagem-google-logo-com-fundo-transparente-1-300x300.png',
                            height: 50.0),
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage()));
                        },
                        child: FadeInUp(
                            duration: Duration(milliseconds: 2000),
                            child: const Text(
                              "Quiero registrarme",
                              style: TextStyle(
                                  color: Color.fromRGBO(143, 148, 251, 1)),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cvault/views/pages/LoginPage.dart'; // Importa tu LoginPage
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      title: 'Google Sign In',
      home: LoginPage(), // Cambia esto a LoginPage
    ),
  );
}
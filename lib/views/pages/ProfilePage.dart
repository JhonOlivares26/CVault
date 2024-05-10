import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  final User user;

  ProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Nombre: ${user.displayName ?? 'No disponible'}'),
            Text('Email: ${user.email ?? 'No disponible'}'),
            // Agrega más campos según sea necesario
          ],
        ),
      ),
    );
  }
}
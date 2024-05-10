import 'package:flutter/material.dart';
import 'package:cvault/widgets/Navbar.dart';
import 'package:cvault/widgets/Footer.dart'; // Importa el widget Footer
import 'package:cvault/views/pages/CreatePost.dart'; // Asegúrate de reemplazar 'cvault' con el nombre de tu proyecto

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavBar(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Welcome to the Home Page!',
                    style: TextStyle(fontSize: 24),
                  ),
                  ElevatedButton(
                    child: Text('Crear Post'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreatePostPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Footer(), // Aquí se utiliza el widget Footer
        ],
      ),
    );
  }
}
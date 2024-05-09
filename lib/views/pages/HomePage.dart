import 'package:flutter/material.dart';
import 'package:cvault/widgets/Navbar.dart';
import 'package:cvault/views/pages/CreatePost.dart'; // Asegúrate de reemplazar 'cvault' con el nombre de tu proyecto

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavBar(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
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
    );
  }
}
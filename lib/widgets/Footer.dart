import 'package:flutter/material.dart';
import 'package:cvault/views/pages/CreatePost.dart';
import 'package:cvault/views/pages/HomePage.dart';
import 'package:cvault/views/pages/NotificationPage.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // Define la altura del pie de página
      color: Colors.blue, // Define el color del pie de página
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Centra los botones en el espacio disponible
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.home), // Icono para la página de inicio
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.add_box), // Icono para crear un post
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications), // Icono para notificaciones
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
            },
          ),
        ],
      ),
    );
  }
}
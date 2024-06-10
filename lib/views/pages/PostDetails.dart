import 'package:flutter/material.dart';
import 'package:cvault/services/post_service.dart'; // Importa el servicio PostService

class PostDetails extends StatelessWidget {
  final String userId;
  final String title;
  final String imageUrl;
  final String description;
  final int likes;
  
  PostDetails({
    required this.userId,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.likes,
  });

  final PostService _postService = PostService(); // Instancia del servicio PostService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FutureBuilder<String>(
              future: _postService.getUserPhoto(userId), // Obtén la URL de la foto de perfil mediante el servicio PostService
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Muestra un indicador de carga mientras se obtiene la URL de la foto de perfil
                } else if (snapshot.hasError) {
                  return Text('Error al obtener la foto de perfil del usuario'); // Muestra un mensaje de error si hay algún problema al obtener la URL de la foto de perfil
                } else {
                  return Container(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data!), // Utiliza la URL de la foto de perfil obtenida
                          radius: 24.0,
                        ),
                        SizedBox(width: 12.0),
                        FutureBuilder<String>(
                          future: _postService.getUserName(userId), // Obtén el nombre de usuario mediante el servicio PostService
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator(); // Muestra un indicador de carga mientras se obtiene el nombre del usuario
                            } else if (snapshot.hasError) {
                              return Text('Error al obtener el nombre del usuario'); // Muestra un mensaje de error si hay algún problema al obtener el nombre del usuario
                            } else {
                              return Text(
                                snapshot.data!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ); // Muestra el nombre del usuario obtenido del servicio
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    description,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.thumb_up,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    '$likes',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
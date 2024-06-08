import 'package:cvault/views/pages/CreateJob.dart';
import 'package:cvault/views/pages/JobsPage.dart';
import 'package:flutter/material.dart';
import 'package:cvault/views/pages/CreatePost.dart';
import 'package:cvault/views/pages/HomePage.dart';
import 'package:cvault/views/pages/NotificationPage.dart';
import 'package:cvault/services/user_service.dart';
import 'package:cvault/models/User.dart' as uuser;
import 'package:firebase_auth/firebase_auth.dart';

class Footer extends StatelessWidget {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userService.getUser(FirebaseAuth.instance.currentUser?.uid),
      builder: (BuildContext context, AsyncSnapshot<uuser.User> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(); // Muestra un contenedor vacío mientras se obtiene el usuario
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Muestra un mensaje de error si algo sale mal
        } else {
          uuser.User user = snapshot.data!;

          return Container(
            height: 60,
            color: Colors.blue.withOpacity(0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.home, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                if (user.userType == 'Persona')
                IconButton(
                  icon: Icon(Icons.work, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => JobsPage()));
                  },
                ),
                  IconButton(
                    icon: Icon(Icons.add_box, color: Colors.white),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CreatePostPage()));
                    },
                  ),
                  IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => NotificationPage()));
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
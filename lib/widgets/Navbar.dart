import 'package:cvault/views/pages/ApplicationsPage.dart';
import 'package:cvault/views/pages/CompanyJobs.dart';
import 'package:cvault/views/pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cvault/views/pages/UserPosts.dart';
import 'package:cvault/views/pages/ProfilePage.dart';
import 'package:cvault/models/User.dart' as uuser;
import 'package:cvault/services/user_service.dart';

class NavBar extends StatelessWidget {
  final UserService _userService = UserService();
  final Widget body;

  NavBar({required this.body});

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

          return Scaffold(
            appBar: AppBar(
              title: Text('Home Page'),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      'Menú',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Perfil'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                ),
                ListTile(
                  leading: const  Icon(Icons.settings),
                  title: const Text('Configuración'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.article),
                  title: const Text("Posts"),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => UserPostPage()));
                  },
                ),
                if (user.userType == 'Persona')                
                ListTile(
                  leading: const Icon(Icons.bookmark_outlined),
                  title: const Text("Postulaciones"),
                  onTap: () {             
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ApplicationsPage()));
                  },
                ),
                if (user.userType == 'empresa') 
                ListTile(
                  leading: const Icon(Icons.work_outlined),
                  title: const Text("Empleos publicados"),
                  onTap: () {             
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CompanyJobsPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Cerrar sesión'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
          body: body,
          );
        }
      },
    );
  }
}
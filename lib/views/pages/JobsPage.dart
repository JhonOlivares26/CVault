import 'package:cvault/views/pages/CreateJob.dart';
import 'package:flutter/material.dart';
import 'package:cvault/widgets/Navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cvault/widgets/Footer.dart';
import 'package:cvault/widgets/JobItem.dart';
import 'package:cvault/models/Job.dart';
import 'package:cvault/services/user_service.dart';
import 'package:cvault/models/User.dart' as uuser;
import 'package:firebase_auth/firebase_auth.dart';

class JobsPage extends StatelessWidget {
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

          return NavBar(
            body: Column(
              children: <Widget>[
                if (user.userType == 'empresa')
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateJobPage()),
                      );
                    },
                    child: Text('Crear empleo'),
                  ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('jobs').snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Algo salió mal');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Cargando");
                      }
                      if (snapshot.data == null) {
                        return const Text("No hay datos");
                      }
                      return ListView(
                        children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          Job job = Job.fromMap(document.data() as Map<String, dynamic>);
                          return SizedBox(
                            height: 120,
                            child: JobItem(job: job),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                Footer(),
              ],
            ),
          );
        }
      },
    );
  }
}
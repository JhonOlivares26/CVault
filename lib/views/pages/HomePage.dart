import 'package:flutter/material.dart';
import 'package:cvault/widgets/Navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cvault/widgets/Footer.dart';
import 'package:cvault/widgets/PostItem.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NavBar(
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    return SizedBox(
                      height: 120,
                      child: PostItem(post: document),
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
}

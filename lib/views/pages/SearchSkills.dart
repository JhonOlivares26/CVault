import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchSkills extends StatefulWidget {
  @override
  _SearchSkillsState createState() => _SearchSkillsState();
}

class _SearchSkillsState extends State<SearchSkills> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar por Habilidades'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar habilidades...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _searchQuery =
                          _searchController.text.trim().toUpperCase();
                    });
                  },
                ),
              ),
              onSubmitted: (query) {
                setState(() {
                  _searchQuery = query.trim().toUpperCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersCollection.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No se encontraron usuarios.'));
                }

                // Filtrar los resultados en el cliente
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final userData = doc.data() as Map<String, dynamic>;
                  final skills =
                      (userData['skills'] ?? '').toString().toUpperCase();
                  return skills.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(child: Text('No se encontraron usuarios.'));
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final userDoc = filteredDocs[index];
                    final userData = userDoc.data() as Map<String, dynamic>;
                    final skills = (userData['skills'] ?? '').toString();

                    return ListTile(
                      leading: userData['photo'] != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(userData['photo']),
                            )
                          : CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                      title: Text(userData['name'] ?? 'Sin nombre'),
                      subtitle:
                          Text(skills.length < 2 ? 'Sin habilidades' : skills),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

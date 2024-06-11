import 'package:cvault/views/pages/JobDetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'JobsCompanyDetails.dart';
import 'package:cvault/views/pages/JobsCompanyDetails.dart';

class CompanyJobsPage extends StatefulWidget {
  @override
  _CompanyJobsPageState createState() => _CompanyJobsPageState();
}

class _CompanyJobsPageState extends State<CompanyJobsPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trabajos publicados'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .where('companyId', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Ha ocurrido un error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: const Text("No hay trabajos publicados"));
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Text(data['title'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 5),
                      Text(data['description'], style: TextStyle(fontSize: 14)),
                      SizedBox(height: 10),
                      Text('Lugar: ${data['location']}',
                          style: TextStyle(fontSize: 14)),
                      Text('Salario: ${data['salary']}',
                          style: TextStyle(fontSize: 14)),
                      Text('Modalidad: ${data['modality']}',
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobsCompanyDetails(jobData: data),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

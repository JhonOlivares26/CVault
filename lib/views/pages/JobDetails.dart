import 'package:flutter/material.dart';
import 'package:cvault/models/Job.dart';
import 'package:cvault/models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class JobDetailsPage extends StatefulWidget {
  final Job job;
  final User user; // Añade un usuario al constructor de la página
  final currentUser = auth.FirebaseAuth.instance.currentUser;

  JobDetailsPage({required this.job, required this.user});

  @override
  _JobDetailsPageState createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('${widget.job.title}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Company: ${widget.job.companyName}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Location: ${widget.job.location}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Salary: ${widget.job.salary}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Modality: ${widget.job.modality}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Acerca del empleo: ${widget.job.description}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Solicitantes: ${widget.job.applicants.length}'),
            ElevatedButton(
              child: Text('Solicitar empleo'),
              onPressed: () {
                final currentUser = auth.FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  if (!widget.job.applicants.contains(currentUser.uid)) {
                    setState(() {
                      widget.job.applicants.add(currentUser.uid);
                    });

                    // Guardar la información en Firebase
                    FirebaseFirestore.instance.collection('jobs').doc(widget.job.id).update({
                      'applicants': FieldValue.arrayUnion([currentUser.uid]) // Guarda solo el id del usuario
                    });
                  } else {
                    // Manejar el caso en que el usuario ya ha solicitado el empleo
                  }
                } else {
                  // Manejar el caso en que no hay usuario autenticado
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cvault/models/Job.dart';
import 'package:cvault/models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cvault/widgets/Alert.dart';

class JobDetailsPage extends StatefulWidget {
  final Job job;
  final User user;

  JobDetailsPage({required this.job, required this.user});

  @override
  _JobDetailsPageState createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  bool hasApplied = false;
  String userType = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserType();
  }

  Future<void> _getUserType() async {
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      setState(() {
        userType = userDoc.data()?['userType'] ?? '';
        hasApplied = widget.job.applicants.contains(currentUser.uid);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job.title),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.job.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.business),
                      title: Text('Compañia'),
                      subtitle: Text(widget.job.companyName),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('Lugar'),
                      subtitle: Text(widget.job.location),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.monetization_on),
                      title: Text('Salario'),
                      subtitle: Text(widget.job.salary),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.work),
                      title: Text('Modalidad'),
                      subtitle: Text(widget.job.modality),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Acerca del empleo:',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.job.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Divider(),
                  Text('Solicitantes: ${widget.job.applicants.length}'),
                  const SizedBox(height: 20),
                  if (userType == 'Persona')
                    ElevatedButton.icon(
                      onPressed: hasApplied
                          ? null
                          : () async {
                              final currentUser =
                                  auth.FirebaseAuth.instance.currentUser;
                              if (currentUser != null) {
                                if (!widget.job.applicants
                                    .contains(currentUser.uid)) {
                                  final userDoc = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(currentUser.uid)
                                      .get();
                                  final userPdf =
                                      userDoc.data()?['userPdf'] ?? '';
                                  if (userPdf.isEmpty) {
                                    showAlert(
                                      context,
                                      'Error',
                                      'Debes cargar tu hoja de vida antes de postularte a un trabajo.',
                                    );
                                  } else {
                                    setState(() {
                                      widget.job.applicants
                                          .add(currentUser.uid);
                                      hasApplied = true;
                                    });

                                    FirebaseFirestore.instance
                                        .collection('jobs')
                                        .doc(widget.job.id)
                                        .update({
                                      'applicants': FieldValue.arrayUnion(
                                          [currentUser.uid])
                                    });
                                    showAlert(
                                      context,
                                      'Postulación exitosa',
                                      'Has solicitado el empleo exitosamente.',
                                    );
                                  }
                                }
                              }
                            },
                      icon: Icon(Icons.send),
                      label: Text('Solicitar empleo'),
                    ),
                  if (hasApplied)
                    const Text(
                      'Ya estás postulado para este empleo',
                      style: TextStyle(fontSize: 18, color: Colors.green),
                    ),
                ],
              ),
            ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:cvault/models/User.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class JobsCompanyDetails extends StatefulWidget {
  final Map<String, dynamic> jobData;

  JobsCompanyDetails({required this.jobData});

  @override
  _JobsCompanyDetailsState createState() => _JobsCompanyDetailsState();
}

class _JobsCompanyDetailsState extends State<JobsCompanyDetails> {
  Future<List<User>>? userTypeAndApplicantsFuture;
  bool hasApplied = false;
  String userType = '';
  List<User> applicants = [];

  @override
  void initState() {
    super.initState();
    userTypeAndApplicantsFuture = _getUserTypeAndApplicants();
  }

  Future<List<User>> _getUserTypeAndApplicants() async {
    List<User> datos = [];
    print('Iniciando _getUserTypeAndApplicants');
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      setState(() {
        userType = userDoc.data()?['userType'] ?? '';
        hasApplied = widget.jobData['applicants'].contains(currentUser.uid); // Usa widget.jobData en lugar de widget.job
      });

      if (userType == 'Empresa') {
        for (String applicantId in widget.jobData['applicants']) { // Usa widget.jobData en lugar de widget.job
          final applicantDoc = await FirebaseFirestore.instance.collection('users').doc(applicantId).get();
          datos.add(User.fromFirestore(applicantDoc)); // Usamos fromFirestore en lugar de fromDocument
        }
      }
    }
    print('Finalizando _getUserTypeAndApplicants');
    print('Datos devueltos por _getUserTypeAndApplicants: $datos');
    return Future.value(datos);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Detalles del trabajo'),
    ),
    body: FutureBuilder<List<User>>(
        future: userTypeAndApplicantsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            if (snapshot.hasData) {
              List<User> applicants = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Descripción del trabajo: ${widget.jobData['description']}'),
                  Text('Salario: ${widget.jobData['salary']}'),
                  Text('Modalidad: ${widget.jobData['modality']}'),
                  Text('Ubicación: ${widget.jobData['location']}'),
                  if (userType == 'Empresa')
                    Expanded(
                      child: ListView.builder(
                        itemCount: applicants.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(applicants[index].name),
                            subtitle: Text(applicants[index].skills),
                            onTap: () async {
                              String url = applicants[index].userPdf!;
                              final response = await http.get(Uri.parse(url));

                              if (response.statusCode == 200) {
                                final Uint8List bytes = response.bodyBytes;

                                final tempDir = await getTemporaryDirectory();
                                final tempPath = tempDir.path;

                                final File file = File('$tempPath/profile.pdf');

                                await file.writeAsBytes(bytes);

                                OpenFile.open(file.path);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Error al descargar el PDF'),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              );
            } else {
              return Text('No hay datos disponibles');
            }
          }
        },
      ),
    );
  }
}
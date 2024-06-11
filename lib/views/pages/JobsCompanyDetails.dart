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
  final _formKey = GlobalKey<FormState>();

  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _salaryController = TextEditingController();
  TextEditingController _modalityController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userTypeAndApplicantsFuture = _getUserTypeAndApplicants();
    _initializeControllers();
  }

  void _initializeControllers() {
    _descriptionController.text = widget.jobData['description'] ?? '';
    _salaryController.text = widget.jobData['salary'] ?? '';
    _modalityController.text = widget.jobData['modality'] ?? '';
    _locationController.text = widget.jobData['location'] ?? '';
  }

  Future<List<User>> _getUserTypeAndApplicants() async {
    List<User> datos = [];
    print('Iniciando _getUserTypeAndApplicants');
    final currentUser = auth.FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      setState(() {
        userType = userDoc.data()?['userType'] ?? '';
        hasApplied = widget.jobData['applicants'].contains(currentUser.uid);
      });

      if (userType == 'Empresa') {
        for (String applicantId in widget.jobData['applicants']) {
          final applicantDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(applicantId)
              .get();
          datos.add(User.fromFirestore(applicantDoc));
        }
      }
    }
    print('Finalizando _getUserTypeAndApplicants');
    print('Datos devueltos por _getUserTypeAndApplicants: $datos');
    return Future.value(datos);
  }

  Future<void> _saveJobDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.jobData['id'])
          .update({
        'description': _descriptionController.text,
        'salary': _salaryController.text,
        'modality': _modalityController.text,
        'location': _locationController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actualizado correctamente.')),
      );
    }
  }

  Future<void> _deleteJob() async {
    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobData['id'])
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Eliminado correctamente.')),
    );
    Navigator.of(context).pop(); // Regresa a la pantalla anterior
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este trabajo?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteJob();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del trabajo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: userTypeAndApplicantsFuture,
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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
              return const Center(child: Text('No hay datos disponibles'));
            }
          }
        },
      ),
    );
  }
}

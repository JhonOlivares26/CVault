import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cvault/models/Job.dart';

class CreateJob extends StatefulWidget {
  @override
  _CreateJobState createState() => _CreateJobState();
}

class _CreateJobState extends State<CreateJob> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Aquí es donde se crea el trabajo
      Job job = Job(
        id: FirebaseFirestore.instance.collection('jobs').doc().id,
        title: _title,
        description: _description,
        companyId: 'id de la empresa', // Reemplaza esto con el id de la empresa actual
        companyName: 'nombre de la empresa', // Reemplaza esto con el nombre de la empresa actual
        applicants: [],
      );

      createJob(job);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Empleo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _submit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text('Crear un nuevo empleo', style: TextStyle(fontSize: 30.0)),
                SizedBox(height: 30.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Título del empleo'),
                  validator: (input) => input!.trim().length < 1 ? 'Por favor, introduce un título válido' : null,
                  onSaved: (input) => _title = input!,
                ),
                SizedBox(height: 15.0),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Descripción del empleo'),
                  validator: (input) => input!.trim().length < 1 ? 'Por favor, introduce una descripción válida' : null,
                  onSaved: (input) => _description = input!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
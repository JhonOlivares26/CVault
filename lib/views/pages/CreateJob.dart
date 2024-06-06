import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cvault/models/Job.dart';
import 'package:cvault/services/jobs_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class CreateJobPage extends StatefulWidget {
  @override
  _CreateJobPageState createState() => _CreateJobPageState();
}

class _CreateJobPageState extends State<CreateJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _jobService = JobService();

  String _title = '';
  String _description = '';
  String _location = 'California';
  String _modality = 'Remoto';
  int? _salary = 0;

  // Opciones para los campos de modalidad y ubicación
  List<String> _modalityOptions = ['Remoto', 'Presencial', 'Mixto'];
  List<String> _locationOptions = ['Medellín', 'Bogotá', 'California', 'Otro lugar'];

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Obtiene el userId del usuario actual
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // Aquí es donde se crea el trabajo
      Job job = Job(
        id: '', // El ID se generará en JobService
        title: _title,
        description: _description,
        location: _location,
        modality: _modality,
        salary: _salary.toString(),
        companyId: userId!, // Usa el userId como companyId
        companyName: 'nombre de la empresa', // Reemplaza esto con el nombre de la empresa actual
        applicants: [],
      );

      _jobService.createJob(job);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Empleo'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 30.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Cargo del empleo'),
                  validator: (input) => input!.trim().length < 1 ? 'Por favor, introduce un título válido' : null,
                  onSaved: (input) => _title = input!,
                ),
                const SizedBox(height: 15.0),
                DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: 'Modalidad'),
                  value: _modality,
                  items: _modalityOptions.map((String option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _modality = value.toString();
                    });
                  },
                ),
                const SizedBox(height: 15.0),
                DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: 'Ubicación'),
                  value: _location,
                  items: _locationOptions.map((String option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _location = value.toString();
                    });
                  },
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Descripción del empleo'),
                  validator: (input) => input!.trim().length < 1 ? 'Por favor, introduce una descripción válida' : null,
                  onSaved: (input) => _description = input!,
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Salario'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ], // Solo números enteros positivos
                  validator: (input) => input != null && int.tryParse(input) == null ? 'Por favor, introduce un salario válido' : null,
                  onSaved: (input) => _salary = int.tryParse(input!),
                ),
                const SizedBox(height: 15.0),
                ElevatedButton(
                    child: Text('Crear empleo'),
                    onPressed: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
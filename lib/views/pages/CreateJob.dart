import 'package:flutter/material.dart';
import 'package:cvault/models/Job.dart';
import 'package:cvault/services/jobs_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cvault/services/user_service.dart';
import 'package:cvault/widgets/Alert.dart';

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
  List<String> _locationOptions = ['Medellín', 'Bogotá', 'California', 'Buenos Aires'];

  final UserService _userService = UserService();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Obtiene el userId del usuario actual
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // Obtiene la información del usuario actual
      final user = await _userService.getUser(userId);

      // Aquí es donde se crea el trabajo
      Job job = Job(
        id: '', // El ID se generará en JobService
        title: _title,
        description: _description,
        location: _location,
        modality: _modality,
        salary: _salary.toString(),
        companyId: userId!, // Usa el userId como companyId
        companyName: user.name, 
        applicants: [],
      );

      _jobService.createJob(job);

      showAlert(
        context,
        'Postulación exitosa',
        'Has solicitado el empleo exitosamente.',
      );
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
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return _locationOptions; // Devuelve todas las opciones si el usuario no ha escrito nada
                    }
                    return _locationOptions.where((String option) {
                      return option.contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    setState(() {
                      _location = selection;
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
                    onPressed: _submitForm,
                    child: const Text('Crear empleo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
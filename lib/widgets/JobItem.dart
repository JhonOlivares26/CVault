import 'package:flutter/material.dart';
import 'package:cvault/models/Job.dart';

class JobItem extends StatelessWidget {
  final Job job;
  JobItem({required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.work), // Puedes cambiar esto por una imagen o icono relevante
        title: Text(job.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(job.companyName),
            Text(job.description),
            Text(job.location),
            Text(job.salary.toString()),
          ],
        ),
        onTap: () {
          // Aquí puedes manejar lo que sucede cuando se toca el elemento
          // Por ejemplo, navegar a una nueva pantalla con los detalles del trabajo
        },
      ),
    );
  }
}
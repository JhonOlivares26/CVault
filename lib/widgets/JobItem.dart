import 'package:cvault/views/pages/JobDetails.dart';
import 'package:flutter/material.dart';
import 'package:cvault/models/Job.dart';
import 'package:cvault/models/User.dart';
import 'package:cvault/services/user_service.dart'; // Asegúrate de importar tu servicio de usuario

class JobItem extends StatefulWidget {
  final Job job;
  JobItem({required this.job});

  @override
  _JobItemState createState() => _JobItemState();
}

class _JobItemState extends State<JobItem> {
  late Future<User> _userFuture;
  final UserService _userService = UserService(); // Crea una instancia de UserService

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUser(widget.job.companyId); // Llama a getUser en la instancia de UserService
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Muestra un indicador de carga mientras se espera la respuesta
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          User user = snapshot.data!;
            return Card(
              child: ListTile(
                leading: user.photo != null ? Image.network(user.photo!) : Icon(Icons.image),
                title: Text(widget.job.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.job.companyName),
                    Text(widget.job.location),
                    Text(widget.job.salary.toString()),
                    Text(widget.job.modality)
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailsPage(job: widget.job, user: user)));
                },
              ),
            );
        }
      },
    );
  }
}
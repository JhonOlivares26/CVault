import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
      ),
      body: Center(
        child: Text(
          'Aquí aparecerán las notificaciones',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
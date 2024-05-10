import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  ConfirmationDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el diálogo
          },
        ),
        TextButton(
          child: Text('Confirmar'),
          onPressed: () {
            onConfirm(); // Llama a la función de confirmación
            Navigator.of(context).pop(); // Cierra el diálogo
          },
        ),
      ],
    );
  }
}
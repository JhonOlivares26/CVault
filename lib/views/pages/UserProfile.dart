import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfile extends StatelessWidget {
  final Map<String, dynamic> userData;
  final BuildContext context; // Agregamos context como parámetro

  UserProfile({required this.userData, required this.context});

  Future<void> downloadAndOpenPdf(String pdfUrl) async {
    final response = await http.get(Uri.parse(pdfUrl));

    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;

      final File file = File('$tempPath/${userData['name']}.pdf');

      await file.writeAsBytes(bytes);

      OpenFile.open(file.path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar el PDF'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userData['name'] ?? 'Perfil de Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (userData['photo'] != null)
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(userData['photo']),
                  radius: 80,
                ),
              ),
            SizedBox(height: 16),
            Text(
              'Nombre: ${userData['name'] ?? 'Sin nombre'}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Habilidades: ${userData['skills'] ?? 'Sin habilidades'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Contacto: ${userData['email'] ?? 'Sin email'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            if (userData['userPdf'] != null)
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await downloadAndOpenPdf(userData['userPdf']!);
                  },
                  child: Text('Ver CV'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

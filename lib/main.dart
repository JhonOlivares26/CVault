import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cvault/controllers/firebase_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MaterialApp(
      title: 'Google Sign In',
      home: SignInDemo(),
    ),
  );
}

class SignInDemo extends StatefulWidget {
  const SignInDemo({super.key});

  @override
  State createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign In'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            child: Text('SIGN IN'),
            onPressed: () async {
              User? user = await FirebaseService.signInGoogle();
              print(user);
            },
          ),
           ElevatedButton(
            child: Text('SIGN IN GITHUB'),
            onPressed: () async {
              User? user = await FirebaseService.signInGithub();
              print(user);
            },
          ),
        ],
      ),
    );
  }
}

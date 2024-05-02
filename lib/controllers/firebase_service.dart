import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static Future<User?> firebaseInit() async {
    FirebaseApp app = await Firebase.initializeApp();
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No ha iniciado sesion");
    }
    return user;
  }

  static Future<User?> signInGithub() async {
    try {
      GithubAuthProvider provider = GithubAuthProvider();

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithProvider(provider);

    return userCredential.user;
    } catch (e) {
      print(e);
    }
    
  }

  static Future<User?> signInGoogle() async {
    GoogleSignIn signIn = GoogleSignIn(scopes: ['email']);

    GoogleSignInAccount? googleSignInAccount = await signIn.signIn();
    if (googleSignInAccount != null) {
      GoogleSignInAuthentication authentication =
          await googleSignInAccount.authentication;

      OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: authentication.accessToken,
          idToken: authentication.idToken);

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential.user;
    }
  }
}
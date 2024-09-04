import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyBoDfp5GVJdIDCZNS4B1WAJt3C_0r4xC5w", // Votre API Key Web
      appId: "1:714405681197:android:5005e36d5669178bcbc0a4",
      messagingSenderId: "714405681197",
      projectId: "gestionticket-11104",
      storageBucket: "gestionticket-11104.appspot.com",
    );
  }
}

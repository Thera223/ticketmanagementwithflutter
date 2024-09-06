import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestionticket/appconfirm.dart';
import 'package:gestionticket/applistvide.dart';
import 'package:gestionticket/bienvenumobile.dart';
import 'package:gestionticket/chat_page.dart';
import 'package:gestionticket/chatapp.dart';
import 'package:gestionticket/create_ticket_page.dart';
import 'package:gestionticket/creergroup.dart';
import 'package:gestionticket/discussion.dart';
import 'package:gestionticket/inscription.dart';
import 'package:gestionticket/login_page.dart';
import 'package:gestionticket/apprenant_home_page.dart';
import 'package:gestionticket/formateur_home_page.dart';
import 'package:gestionticket/notification_page.dart';
import 'package:gestionticket/profile_page.dart';
import 'package:gestionticket/reponseticket.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserRoleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomePage(), // Page de démarrage
      routes: {
        '/register': (context) => const RegistrationPage(),
        '/apprenant_home': (context) => const ApprenantHomePage(),
        '/formateur_home': (context) => const FormateurHomePage(),
        '/submit_ticket': (context) => const SubmitTicketForm(),
        '/confirmation': (context) => const ConfirmationPage(),
        '/error': (context) => const ErrorPage(),
        '/profile': (context) {
          final userRole = context.watch<UserRoleProvider>().role;
          if (userRole == 'Apprenant') {
            return const ProfilePage(); // Profil pour apprenant
          } else if (userRole == 'Formateur') {
            return const ProfilePage(); // Profil pour formateur
          }
          return const ProfilePage(); // Profil par défaut
        },
        '/chatform': (context) => ChatGroupsPageFormateur(),
        '/chatapre': (context) => ChatGroupsPageApprenant(),
        '/notifications': (context) {
          final userRole = context.watch<UserRoleProvider>().role;
          if (userRole == 'Apprenant') {
            return  NotificationPage(); // Notification pour apprenant
          } else if (userRole == 'Formateur') {
            return NotificationPage(); // Notification pour formateur
          }
          return  NotificationPage(); // Notification par défaut
        },
        '/create_chat_group': (context) => const CreateChatGroupPage(),
        '/login': (context) => const LoginPagem(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/discussion') {
          final String groupId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ChatPage(groupId: groupId),
          );
        }
        if (settings.name == '/response_form') {
          final args = settings.arguments as DocumentSnapshot;
          return MaterialPageRoute(
            builder: (context) => ResponseForm(ticket: args),
          );
        }
        return null;
      },
    );
  }
}

class UserRoleProvider with ChangeNotifier {
  String _role = '';

  String get role => _role;

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestionticket/apprenant_home_page.dart';
import 'package:gestionticket/main.dart';
import 'package:provider/provider.dart';



class ProfilePage extends StatefulWidget {

   const ProfilePage({super.key});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}




class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3; // Position initiale de l'onglet

  @override
  Widget build(BuildContext context) {
    // Accédez au rôle de l'utilisateur à partir de UserRoleProvider
    final userRole = context.watch<UserRoleProvider>().role;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'User',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètre'),
              onTap: () {
                // Logique pour les paramètres
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique'),
              onTap: () {
                // Logique pour l'historique
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () async {
                // Déconnexion de l'utilisateur
                await FirebaseAuth.instance.signOut();

                // Redirection vers la page de connexion
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onItemTapped(index, userRole),
      ),
    );
  }

  void _onItemTapped(int index, String userRole) {
    setState(() {
      _currentIndex = index;
    });

    // Redirige vers la page appropriée en fonction du rôle de l'utilisateur
    switch (index) {
      case 0:
        Navigator.pushNamed(context,
            userRole == 'Apprenant' ? '/apprenant_home' : '/formateur_home');
        break;
      case 1:
        Navigator.pushNamed(
            context, userRole == 'Apprenant' ? '/chatapre' : '/chatform');
        break;
      case 2:
        Navigator.pushNamed(context, '/notifications');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}

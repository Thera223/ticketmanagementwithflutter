import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestionticket/apprenant_home_page.dart';
import 'package:gestionticket/main.dart';
import 'package:provider/provider.dart';

class ChatGroupsPageApprenant extends StatefulWidget {
  @override
  State<ChatGroupsPageApprenant> createState() => _ChatGroupsPageApprenantState();
}

class _ChatGroupsPageApprenantState extends State<ChatGroupsPageApprenant> {
  final String apprenantId = FirebaseAuth.instance.currentUser!.uid;
  int _currentIndex = 1; // Position initiale de l'onglet

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
  @override
  Widget build(BuildContext context) {
        final userRole = context.watch<UserRoleProvider>().role;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Groupes de Chat (Apprenant)',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 20, 67, 168),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groupes_de_chat')
            .where('membres', arrayContains: apprenantId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final groups = snapshot.data!.docs;

          if (groups.isEmpty) {
            return const Center(child: Text('Aucun groupe de chat trouvé.'));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              var group = groups[index].data() as Map<String, dynamic>;
              String groupName = group['nomGroupe'] ?? 'Nom non défini';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    groupName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/discussion',
                      arguments: groups[index].id,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ouverture du groupe: $groupName'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
       bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => _onItemTapped(index, userRole),
        )
    );
  }
  
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestionticket/apprenant_home_page.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  int _currentIndex = 2; // Position initiale de l'onglet


  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/apprenant_home');
        break;
      case 1:
        Navigator.pushNamed(context, '/chatapre');
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
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        final userRole =
            snapshot.data!['role']; // Récupère le rôle de l'utilisateur

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            backgroundColor: const Color.fromARGB(255, 8, 58, 223),
            elevation: 1,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('invitations')
                .where(userRole == 'Apprenant' ? 'apprenantId' : 'formateurId',
                    isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final invitations = snapshot.data!.docs;

              if (invitations.isEmpty) {
                return const Center(
                    child: Text('Aucune notification trouvée.'));
              }

              return ListView.builder(
                itemCount: invitations.length,
                itemBuilder: (context, index) {
                  var invitation =
                      invitations[index].data() as Map<String, dynamic>;
                  String status = invitation['status'] ?? 'pending';
                  String apprenantId = invitation['apprenantId'];
                  String formateurId = invitation['formateurId'];
                  String? groupId = invitation['groupId'];

                  if (userRole == 'Apprenant') {
                    return ListTile(
                      title: Text('Demande de contact'),
                      subtitle: Text(
                          'Statut: ${status == 'accepted' ? 'Acceptée' : status == 'rejected' ? 'Rejetée' : 'En attente'}'),
                      onTap: () {
                        if (status == 'accepted' && groupId != null) {
                          Navigator.pushNamed(context, '/discussion',
                              arguments: groupId);
                        }
                      },
                    );
                  } else if (userRole == 'Formateur') {
                    // Utiliser FutureBuilder pour récupérer le nom de l'apprenant
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(apprenantId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const ListTile(
                            title: Text('Chargement...'),
                          );
                        }

                        String apprenantNom = userSnapshot.data!.exists
                            ? userSnapshot.data!['name'] ?? 'Nom non défini'
                            : 'Utilisateur inconnu';

                        return ListTile(
                          title: Text('Demande de contact de $apprenantNom'),
                          subtitle: Text(
                              'Statut: ${status == 'pending' ? 'En attente' : status == 'accepted' ? 'Acceptée' : 'Rejetée'}'),
                          trailing: status == 'pending'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.group_add,
                                          color: Colors.blue),
                                      onPressed: () => _manageInvitation(
                                          context,
                                          invitations[index].id,
                                          apprenantId,
                                          formateurId),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      onPressed: () => _rejectInvitation(
                                          invitations[index].id),
                                    ),
                                  ],
                                )
                              : null,
                        );
                      },
                    );
                  }
                  return const SizedBox(); // Si aucun rôle valide
                },
              );
            },
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }

  void _manageInvitation(BuildContext context, String invitationId,
      String apprenantId, String formateurId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Gérer l\'invitation'),
          content: Text(
              'Voulez-vous créer un nouveau groupe ou ajouter à un groupe existant ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _createNewGroup(
                    context, invitationId, apprenantId, formateurId);
              },
              child: Text('Créer un nouveau groupe'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showExistingGroups(
                    context, invitationId, apprenantId, formateurId);
              },
              child: Text('Ajouter à un groupe existant'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createNewGroup(BuildContext context, String invitationId,
      String apprenantId, String formateurId) async {
    DocumentReference groupRef =
        FirebaseFirestore.instance.collection('groupes_de_chat').doc();

    await groupRef.set({
      'formateurId': formateurId,
      'nomGroupe': 'Groupe',
      'membres': [formateurId, apprenantId],
      'tickets': [],
    });

    await FirebaseFirestore.instance
        .collection('invitations')
        .doc(invitationId)
        .update({
      'groupId': groupRef.id,
      'status': 'accepted',
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Groupe créé et apprenant ajouté avec succès')),
      );
    }
  }

  void _showExistingGroups(BuildContext context, String invitationId,
      String apprenantId, String formateurId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('groupes_de_chat')
              .where('formateurId', isEqualTo: formateurId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final groups = snapshot.data!.docs;

            if (groups.isEmpty) {
              return const Center(child: Text('Aucun groupe trouvé.'));
            }

            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                var group = groups[index].data() as Map<String, dynamic>;
                String groupName = group['nomGroupe'] ?? 'Nom non défini';

                return ListTile(
                  title: Text(groupName),
                  onTap: () async {
                    await FirebaseFirestore.instance
                        .collection('groupes_de_chat')
                        .doc(groups[index].id)
                        .update({
                      'membres': FieldValue.arrayUnion([apprenantId])
                    });

                    await FirebaseFirestore.instance
                        .collection('invitations')
                        .doc(invitationId)
                        .update({
                      'groupId': groups[index].id,
                      'status': 'accepted'
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Apprenant ajouté au groupe existant.')),
                      );
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _rejectInvitation(String invitationId) async {
    await FirebaseFirestore.instance
        .collection('invitations')
        .doc(invitationId)
        .update({'status': 'rejected'});
  }
}

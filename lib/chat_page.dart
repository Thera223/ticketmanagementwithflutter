import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatGroupsPageFormateur extends StatelessWidget {
  final String formateurId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groupes de Chat (Formateur)'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Bouton pour créer un nouveau groupe
            onPressed: () {
              Navigator.pushNamed(context, '/create_chat_group');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            return const Center(child: Text('Aucun groupe de chat trouvé.'));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              var group = groups[index].data() as Map<String, dynamic>;
              String groupName = group['nomGroupe'] ?? 'Nom non défini';
              List<dynamic> membres = group['membres'] ?? [];

              return ListTile(
                title: Text(groupName),
                subtitle: FutureBuilder<List<String>>(
                  future:
                      _getUserNames(membres), // Récupérer les noms des membres
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Chargement des membres...');
                    } else if (snapshot.hasError) {
                      return const Text(
                          'Erreur lors du chargement des membres');
                    } else {
                      return Text('Membres: ${snapshot.data!.join(', ')}');
                    }
                  },
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/discussion',
                    arguments: groups[index].id,
                  );
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'Voir Membres':
                        _showGroupMembers(
                            context, groupName, membres, groups[index].id);
                        break;
                      case 'Ajouter Membre':
                        _addMemberToGroup(context, groups[index].id);
                        break;
                      case 'Modifier Groupe':
                        _editGroupName(context, groups[index].id, groupName);
                        break;
                      case 'Supprimer Groupe':
                        _deleteGroup(context, groups[index].id);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Voir Membres',
                      child: Text('Voir Membres'),
                    ),
                    const PopupMenuItem(
                      value: 'Ajouter Membre',
                      child: Text('Ajouter Membre'),
                    ),
                    const PopupMenuItem(
                      value: 'Modifier Groupe',
                      child: Text('Modifier Groupe'),
                    ),
                    const PopupMenuItem(
                      value: 'Supprimer Groupe',
                      child: Text('Supprimer Groupe'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<String>> _getUserNames(List<dynamic> userIds) async {
    List<String> userNames = [];
    for (String userId in userIds) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        userNames.add(userDoc['name'] ?? 'Nom inconnu');
      } else {
        userNames.add('Nom inconnu');
      }
    }
    return userNames;
  }

  void _showGroupMembers(BuildContext context, String groupName,
      List<dynamic> membres, String groupId) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<String>>(
          future: _getUserNames(membres),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                  child: Text('Erreur lors du chargement des membres'));
            }
            return AlertDialog(
              title: Text('Membres de $groupName'),
              content: ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () =>
                          _removeMemberFromGroup(groupId, membres[index]),
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addMemberToGroup(BuildContext context, String groupId) async {
    List<String> selectedMembers = [];
    List<QueryDocumentSnapshot> usersSnapshot = [];

    // Fetch all users who are "Apprenant"
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Apprenant')
        .get();

    usersSnapshot = snapshot.docs;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un Membre'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: usersSnapshot.length,
                      itemBuilder: (context, index) {
                        String userName = usersSnapshot[index]['name'];
                        String userId = usersSnapshot[index].id;
                        return CheckboxListTile(
                          title: Text(userName),
                          value: selectedMembers.contains(userId),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedMembers.add(userId);
                              } else {
                                selectedMembers.remove(userId);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedMembers.isNotEmpty) {
                        await FirebaseFirestore.instance
                            .collection('groupes_de_chat')
                            .doc(groupId)
                            .update({
                          'membres': FieldValue.arrayUnion(selectedMembers),
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Membres ajoutés avec succès.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Veuillez sélectionner au moins un membre.')),
                        );
                      }
                    },
                    child: const Text('Ajouter'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _editGroupName(
      BuildContext context, String groupId, String currentName) {
    TextEditingController groupNameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le Nom du Groupe'),
          content: TextField(
            controller: groupNameController,
            decoration: const InputDecoration(
              labelText: 'Nom du Groupe',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('groupes_de_chat')
                    .doc(groupId)
                    .update({'nomGroupe': groupNameController.text});

                Navigator.pop(context);
              },
              child: const Text('Modifier'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _deleteGroup(BuildContext context, String groupId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le Groupe'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce groupe ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Oui'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non'),
            ),
          ],
        );
      },
    );

    if (confirm) {
      await FirebaseFirestore.instance
          .collection('groupes_de_chat')
          .doc(groupId)
          .delete();
    }
  }

  void _removeMemberFromGroup(String groupId, String memberId) async {
    await FirebaseFirestore.instance
        .collection('groupes_de_chat')
        .doc(groupId)
        .update({
      'membres': FieldValue.arrayRemove([memberId]),
    });
  }
}

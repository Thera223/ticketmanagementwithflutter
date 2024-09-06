import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestionticket/apprenant_home_page.dart';

class ChatGroupsPageFormateur extends StatefulWidget {
  @override
  State<ChatGroupsPageFormateur> createState() => _ChatGroupsPageFormateurState();
}

class _ChatGroupsPageFormateurState extends State<ChatGroupsPageFormateur> {
  final String formateurId = FirebaseAuth.instance.currentUser!.uid;
   int _currentIndex = 1; // Position initiale de l'onglet

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groupes de Chat (Formateur)',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 20, 67, 168),
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
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

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                child: ListTile(
                  title: Text(groupName,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: FutureBuilder<List<String>>(
                    future: _getUserNames(
                        membres), // Récupérer les noms des membres
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
                ),
              );
            },
          );
        },
      ),
       bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        )
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
            return Dialog(
              insetPadding: const EdgeInsets.all(
                  16), // Espace autour de la boîte de dialogue
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width *
                      0.8, // Largeur maximale de 80% de l'écran
                  maxHeight: MediaQuery.of(context).size.height *
                      0.8, // Hauteur maximale de 80% de l'écran
                ),
                padding: const EdgeInsets.all(
                    16.0), // Espacement interne de la boîte de dialogue
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Membres de $groupName',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(snapshot.data![index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () => _removeMemberFromGroup(
                                  groupId, membres[index]),
                            ),
                          );
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

void _addMemberToGroup(BuildContext context, String groupId) async {
    List<String> selectedMembers = [];
    List<QueryDocumentSnapshot> usersSnapshot = [];

    // Récupération des utilisateurs "Apprenant"
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Apprenant')
        .get();

    usersSnapshot = snapshot.docs;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.all(16), // Espace autour de la boîte de dialogue
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width *
                  0.8, // Largeur maximale de 80% de l'écran
              maxHeight: MediaQuery.of(context).size.height *
                  0.8, // Hauteur maximale de 80% de l'écran
            ),
            padding: const EdgeInsets.all(
                16.0), // Espacement interne de la boîte de dialogue
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ajouter un Membre',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ChatGroupsPageFormateur extends StatelessWidget {
//   final String formateurId = FirebaseAuth.instance.currentUser!.uid;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Groupes de Chat (Formateur)'),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         iconTheme: const IconThemeData(color: Colors.black),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               Navigator.pushNamed(context, '/create_chat_group');
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('groupes_de_chat')
//             .where('formateurId', isEqualTo: formateurId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final groups = snapshot.data!.docs;

//           if (groups.isEmpty) {
//             return const Center(child: Text('Aucun groupe de chat trouvé.'));
//           }

//           return ListView.builder(
//             itemCount: groups.length,
//             itemBuilder: (context, index) {
//               var group = groups[index].data() as Map<String, dynamic>;
//               String groupName = group['nomGroupe'] ?? 'Nom non défini';
//               List<dynamic> membres = group['membres'] ?? [];

//               return ListTile(
//                 title: Text(groupName),
//                 subtitle: FutureBuilder<List<String>>(
//                   future: _getUserNames(membres),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Text('Chargement des membres...');
//                     } else if (snapshot.hasError) {
//                       return const Text(
//                           'Erreur lors du chargement des membres');
//                     } else {
//                       return Text('Membres: ${snapshot.data!.join(', ')}');
//                     }
//                   },
//                 ),
//                 onTap: () {
//                   Navigator.pushNamed(
//                     context,
//                     '/discussion',
//                     arguments: groups[index].id,
//                   );
//                 },
//                 trailing: IconButton(
//                   icon: const Icon(Icons.more_vert),
//                   onPressed: () {
//                     _showGroupOptions(
//                         context, groupName, groups[index].id, membres);
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   void _showGroupOptions(BuildContext context, String groupName, String groupId,
//       List<dynamic> membres) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.group),
//               title: const Text('Voir Membres'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _showGroupMembers(context, groupName, membres, groupId);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.person_add),
//               title: const Text('Ajouter Membre'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _addMemberToGroup(context, groupId);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.edit),
//               title: const Text('Modifier Groupe'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _editGroupName(context, groupId, groupName);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.delete),
//               title: const Text('Supprimer Groupe'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _deleteGroup(context, groupId);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<List<String>> _getUserNames(List<dynamic> userIds) async {
//     List<String> userNames = [];
//     for (String userId in userIds) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .get();
//       if (userDoc.exists) {
//         userNames.add(userDoc['name'] ?? 'Nom inconnu');
//       } else {
//         userNames.add('Nom inconnu');
//       }
//     }
//     return userNames;
//   }

//   void _showGroupMembers(BuildContext context, String groupName,
//       List<dynamic> membres, String groupId) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           insetPadding: const EdgeInsets.all(16),
//           child: Container(
//             constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.8,
//                 maxHeight: MediaQuery.of(context).size.height * 0.8),
//             padding: const EdgeInsets.all(16.0),
//             child: FutureBuilder<List<String>>(
//               future: _getUserNames(membres),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return const Center(
//                       child: Text('Erreur lors du chargement des membres'));
//                 }
//                 return Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text('Membres de $groupName',
//                         style: const TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     Expanded(
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: snapshot.data!.length,
//                         itemBuilder: (context, index) {
//                           return ListTile(
//                             title: Text(snapshot.data![index]),
//                             trailing: IconButton(
//                               icon: const Icon(Icons.remove_circle,
//                                   color: Colors.red),
//                               onPressed: () => _removeMemberFromGroup(
//                                   groupId, membres[index]),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('Fermer'),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }

// void _addMemberToGroup(BuildContext context, String groupId) async {
//   List<String> selectedMembers = [];
//   List<QueryDocumentSnapshot> usersSnapshot = [];

//   // Récupération des utilisateurs "Apprenant"
//   try {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .where('role', isEqualTo: 'Apprenant')
//         .get();

//     usersSnapshot = snapshot.docs;
//   } catch (e) {
//     // Affiche une erreur si la récupération des utilisateurs échoue
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Erreur lors de la récupération des utilisateurs.'),
//       ),
//     );
//     return; // Arrête la fonction si une erreur s'est produite
//   }

//   // Utilisation d'un contexte de niveau supérieur pour afficher la boîte de dialogue
//   if (context.mounted) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: const Text('Ajouter un Membre'),
//           content: StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               return SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.8,
//                 height: MediaQuery.of(context).size.height * 0.6,
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: usersSnapshot.length,
//                         itemBuilder: (context, index) {
//                           String userName = usersSnapshot[index]['name'];
//                           String userId = usersSnapshot[index].id;
//                           return CheckboxListTile(
//                             title: Text(userName),
//                             value: selectedMembers.contains(userId),
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 if (value == true) {
//                                   selectedMembers.add(userId);
//                                 } else {
//                                   selectedMembers.remove(userId);
//                                 }
//                               });
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: () async {
//                         if (selectedMembers.isNotEmpty) {
//                           try {
//                             await FirebaseFirestore.instance
//                                 .collection('groupes_de_chat')
//                                 .doc(groupId)
//                                 .update({
//                               'membres': FieldValue.arrayUnion(selectedMembers),
//                             });

//                             Navigator.pop(dialogContext); // Fermez le dialogue.
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content:
//                                       Text('Membres ajoutés avec succès.')),
//                             );
//                           } catch (e) {
//                             // Affiche une erreur si l'ajout des membres échoue
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                     'Erreur lors de l\'ajout des membres.'),
//                               ),
//                             );
//                           }
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text(
//                                   'Veuillez sélectionner au moins un membre.'),
//                             ),
//                           );
//                         }
//                       },
//                       child: const Text('Ajouter'),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }





//   void _editGroupName(
//       BuildContext context, String groupId, String currentName) {
//     TextEditingController groupNameController =
//         TextEditingController(text: currentName);

//     showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           insetPadding: const EdgeInsets.all(16),
//           child: Container(
//             constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.5),
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text('Modifier le Nom du Groupe',
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 TextField(
//                   controller: groupNameController,
//                   decoration: const InputDecoration(labelText: 'Nom du Groupe'),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () async {
//                         await FirebaseFirestore.instance
//                             .collection('groupes_de_chat')
//                             .doc(groupId)
//                             .update({'nomGroupe': groupNameController.text});
//                         Navigator.pop(context);
//                       },
//                       child: const Text('Modifier'),
//                     ),
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('Annuler'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _deleteGroup(BuildContext context, String groupId) async {
//     bool confirm = await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Supprimer le Groupe'),
//           content: const Text('Êtes-vous sûr de vouloir supprimer ce groupe ?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Oui'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Non'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirm) {
//       await FirebaseFirestore.instance
//           .collection('groupes_de_chat')
//           .doc(groupId)
//           .delete();
//     }
//   }

//   void _removeMemberFromGroup(String groupId, String memberId) async {
//     await FirebaseFirestore.instance
//         .collection('groupes_de_chat')
//         .doc(groupId)
//         .update({
//       'membres': FieldValue.arrayRemove([memberId]),
//     });
//   }
// }

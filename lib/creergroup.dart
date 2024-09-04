import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateChatGroupPage extends StatefulWidget {
  const CreateChatGroupPage({Key? key}) : super(key: key);

  @override
  State<CreateChatGroupPage> createState() => _CreateChatGroupPageState();
}

class _CreateChatGroupPageState extends State<CreateChatGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final String formateurId = FirebaseAuth.instance.currentUser!.uid;
  List<String> selectedApprenants = [];
  List<String> apprenantsIds = [];
  List<String> apprenantsNames = [];

  @override
  void initState() {
    super.initState();
    _fetchApprenants();
  }

  Future<void> _fetchApprenants() async {
    QuerySnapshot responsesSnapshot = await FirebaseFirestore.instance
        .collection('reponseticket')
        .where('formateurId', isEqualTo: formateurId)
        .get();

    List<String> ticketIds =
        responsesSnapshot.docs.map((doc) => doc['ticketId'] as String).toList();

    List<String> ids = [];
    List<String> names = [];

    for (String ticketId in ticketIds) {
      DocumentSnapshot ticketDoc = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .get();

      if (ticketDoc.exists) {
        String apprenantId = ticketDoc['ApprenantId'];

        if (!ids.contains(apprenantId)) {
          DocumentSnapshot apprenantDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(apprenantId)
              .get();

          if (apprenantDoc.exists && apprenantDoc['role'] == 'Apprenant') {
            ids.add(apprenantId);
            names.add(apprenantDoc['name']);
          }
        }
      }
    }

    setState(() {
      apprenantsIds = ids;
      apprenantsNames = names;
    });
  }

  Future<void> _createChatGroup() async {
    if (_groupNameController.text.isEmpty || selectedApprenants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Veuillez entrer un nom de groupe et sélectionner des apprenants')),
      );
      return;
    }

    DocumentReference groupRef =
        FirebaseFirestore.instance.collection('groupes_de_chat').doc();

    await groupRef.set({
      'formateurId': formateurId,
      'nomGroupe': _groupNameController.text,
      'membres': selectedApprenants,
      'tickets': [],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Groupe de chat créé avec succès')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un Groupe de Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Nom du Groupe',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Sélectionner des apprenants:'),
            Expanded(
              child: ListView.builder(
                itemCount: apprenantsIds.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(apprenantsNames[index]),
                    value: selectedApprenants.contains(apprenantsIds[index]),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedApprenants.add(apprenantsIds[index]);
                        } else {
                          selectedApprenants.remove(apprenantsIds[index]);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _createChatGroup,
              child: const Text('Créer le Groupe'),
            ),
          ],
        ),
      ),
    );
  }
}

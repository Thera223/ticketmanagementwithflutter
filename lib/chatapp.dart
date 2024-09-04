import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatGroupsPageApprenant extends StatelessWidget {
  final String apprenantId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groupes de Chat (Apprenant)'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
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

              return ListTile(
                title: Text(groupName),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/discussion',
                    arguments: groups[index].id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

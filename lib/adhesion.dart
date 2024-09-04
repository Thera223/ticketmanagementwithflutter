import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MembershipRequestsPage extends StatefulWidget {
  const MembershipRequestsPage({Key? key}) : super(key: key);

  @override
  _MembershipRequestsPageState createState() => _MembershipRequestsPageState();
}

class _MembershipRequestsPageState extends State<MembershipRequestsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adhésions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pending_users')
                  .where('status', isEqualTo: 'en attente')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final requests = snapshot.data!.docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  final email = doc['email'].toString().toLowerCase();
                  final role = doc['role'].toString().toLowerCase();
                  return name.contains(_searchQuery) ||
                      email.contains(_searchQuery) ||
                      role.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    var request = requests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        title: Text(request['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rôle: ${request['role']}'),
                            Text('Email: ${request['email']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  // Récupérer l'utilisateur de la collection 'pending_users'
                                  DocumentSnapshot<Map<String, dynamic>>
                                      pendingUserDoc = await FirebaseFirestore
                                          .instance
                                          .collection('pending_users')
                                          .doc(request.id)
                                          .get();

                                  // Ajouter l'utilisateur validé à la collection 'users' avec le même ID
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(request.id) // Utiliser le même ID
                                      .set({
                                    'name': pendingUserDoc['name'],
                                    'email': pendingUserDoc['email'],
                                    'role': pendingUserDoc['role'],
                                    'address': pendingUserDoc['address'],
                                    'contact': pendingUserDoc['contact'],
                                    'status': 'validé'
                                  });

                                  // Supprimer l'utilisateur de la collection 'pending_users'
                                  await FirebaseFirestore.instance
                                      .collection('pending_users')
                                      .doc(request.id)
                                      .delete();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Utilisateur validé avec succès')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Erreur lors de la validation : $e')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 27, 12, 235),
                              ),
                              child: const Text('Valider'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('pending_users')
                                    .doc(request.id)
                                    .update({'status': 'Rejeté'});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Refuser'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

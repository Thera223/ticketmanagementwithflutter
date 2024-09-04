import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestionticket/apprenant_home_page.dart';

class FormateurHomePage extends StatefulWidget {
  const FormateurHomePage({Key? key}) : super(key: key);

  @override
  _FormateurHomePageState createState() => _FormateurHomePageState();
}

class _FormateurHomePageState extends State<FormateurHomePage> {
  final String formateurId = FirebaseAuth.instance.currentUser!.uid;
  bool showTickets = true;
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Formateur',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          _buildToggleButtons(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: showTickets ? _buildTicketList() : _buildResponseList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Rechercher',
          prefixIcon: const Icon(Icons.search, color: Colors.black),
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderSide:
                const BorderSide(color: Color.fromARGB(255, 180, 179, 179)),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                const BorderSide(color: Color.fromARGB(255, 180, 179, 179)),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 20, 67, 168), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    const categories = ['Technique', 'Pédagogique', 'Autres'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: categories
              .map((category) => _buildCategoryButton(category))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedCategory = _selectedCategory == category ? null : category;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedCategory == category
              ? const Color.fromARGB(255, 20, 67, 168)
              : Colors.grey.shade600,
        ),
        child: Text(category, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                showTickets = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: showTickets
                  ? const Color.fromARGB(255, 20, 67, 168)
                  : Colors.grey,
            ),
            child: const Text('Tickets', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showTickets = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: !showTickets
                  ? const Color.fromARGB(255, 20, 67, 168)
                  : Colors.grey,
            ),
            child:
                const Text('Réponses', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

Widget _buildTicketList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final tickets = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          bool matchesSearch =
              data['Titre'].toString().toLowerCase().contains(_searchQuery) ||
                  data['Description']
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery);
          bool matchesCategory = _selectedCategory == null ||
              data['categorie'] == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        if (tickets.isEmpty) {
          return const Center(child: Text('Aucun ticket trouvé.'));
        }

        return ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            var ticket = tickets[index].data() as Map<String, dynamic>;

            String titre = ticket['Titre'] ?? 'Titre non défini';
            String description =
                ticket['Description'] ?? 'Description non définie';
            String categorie = ticket['categorie'] ?? 'Catégorie non définie';
            String apprenantId =
                ticket['ApprenantId'] ?? 'ID Apprenant non défini';
            String etat = ticket['Etat'] ?? 'Statut inconnu';

            // Utiliser FutureBuilder pour récupérer le nom de l'utilisateur
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

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(titre,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: $description'),
                        Text('Catégorie: $categorie'),
                        Text('Apprenant: $apprenantNom'),
                        Text('Statut: $etat'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.send,
                          color: Color.fromARGB(255, 20, 67, 168)),
                      onPressed: () {
                        if (etat.toLowerCase() == 'résolu') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ce ticket a déjà été résolu.'),
                            ),
                          );
                        } else {
                          _startResponse(context, tickets[index]);
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TicketDetailPage(ticketData: ticket),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }


// Méthode pour démarrer une réponse
  void _startResponse(BuildContext context, DocumentSnapshot ticket) {
    // Mettre à jour le statut du ticket à 'En cours'
    FirebaseFirestore.instance.collection('tickets').doc(ticket.id).update({
      'Etat': 'Résolu', // Mise à jour du statut
    });

    // Naviguer vers le formulaire de réponse
    Navigator.pushNamed(
      context,
      '/response_form',
      arguments: ticket,
    );
  }


  Widget _buildResponseList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('reponseticket').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final responses = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          bool matchesSearch =
              data['titre'].toString().toLowerCase().contains(_searchQuery) ||
                  data['description']
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery);
          bool matchesCategory = _selectedCategory == null ||
              data['categorie'] == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        if (responses.isEmpty) {
          return const Center(child: Text('Aucune réponse trouvée.'));
        }

        return ListView.builder(
          itemCount: responses.length,
          itemBuilder: (context, index) {
            var response = responses[index].data() as Map<String, dynamic>;

            String titre = response['titre'] ?? 'Titre non défini';
            String description =
                response['description'] ?? 'Description non définie';
            String categorie = response['categorie'] ?? 'Catégorie non définie';
            DateTime? date = (response['Date'] as Timestamp?)?.toDate();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(titre,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: $description'),
                    Text('Catégorie: $categorie'),
                    Text(
                        'Date: ${date != null ? date.toString() : 'Date non définie'}'),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'Modifier':
                        _editResponse(context, responses[index]);
                        break;
                      case 'Supprimer':
                        _deleteResponse(context, responses[index].id);
                        break;
                    }
                  },
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    if (response['formateurId'] == formateurId)
                      const PopupMenuItem<String>(
                        value: 'Modifier',
                        child: Text('Modifier'),
                      ),
                    const PopupMenuItem<String>(
                      value: 'Supprimer',
                      child: Text('Supprimer'),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ResponseDetailPage(responseData: response),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.black), label: 'Chat'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: Colors.black),
            label: 'Notifications'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black), label: 'Profil'),
      ],
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/formateur_home');
            break;
          case 1:
            Navigator.pushNamed(context, '/chatform');
            break;
          case 2:
            Navigator.pushNamed(context, '/notifications');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
    );
  }

  // void _startResponse(BuildContext context, DocumentSnapshot ticket) {
  //   Navigator.pushNamed(
  //     context,
  //     '/response_form',
  //     arguments: ticket,
  //   );
  //   FirebaseFirestore.instance
  //       .collection('tickets')
  //       .doc(ticket.id)
  //       .update({'Etat': 'En cours'});
  // }

void _editResponse(BuildContext context, DocumentSnapshot response) {
  // Créez un TextEditingController pour les champs de texte
  TextEditingController _descriptionController = TextEditingController(text: response['description']);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Modifier la réponse'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description de la réponse'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Ferme la boîte de dialogue
            },
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // Mettre à jour la réponse dans Firestore
              FirebaseFirestore.instance
                  .collection('reponseticket')
                  .doc(response.id)
                  .update({
                'description': _descriptionController.text.trim(),
                'Date': Timestamp.now(), // Mettre à jour la date de modification
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Réponse modifiée avec succès.')),
              );

              Navigator.of(context).pop(); // Ferme la boîte de dialogue après la mise à jour
            },
            child: Text('Enregistrer'),
          ),
        ],
      );
    },
  );
}


  void _deleteResponse(BuildContext context, String responseId) {
    FirebaseFirestore.instance
        .collection('reponseticket')
        .doc(responseId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Réponse supprimée.')),
    );
  }

}
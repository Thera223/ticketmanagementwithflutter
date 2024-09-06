import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestionticket/apprenant_home_page.dart';
import 'package:gestionticket/main.dart';
import 'package:provider/provider.dart';


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
   int _currentIndex = 0; // Position initiale de l'onglet

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

    Widget build(BuildContext context) {
    final userRole = context.watch<UserRoleProvider>().role;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Formateur',
            style: TextStyle(color: Colors.black)),
        backgroundColor: const Color.fromARGB(255, 20, 67, 168),
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
       bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onItemTapped(index, userRole),)
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
          borderSide: const BorderSide(color: Color.fromARGB(255, 180, 179, 179)),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 180, 179, 179)),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 20, 67, 168), width: 2),
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
        children: categories.map((category) => _buildCategoryButton(category)).toList(),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Uniformiser avec les autres boutons
        ),
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
        _buildAnimatedToggleButton(
          isSelected: showTickets,
          label: 'Tickets',
          icon: Icons.assignment,
          onTap: () {
            setState(() {
              showTickets = true;
            });
          },
        ),
        const SizedBox(width: 10),
        _buildAnimatedToggleButton(
          isSelected: !showTickets,
          label: 'Réponses',
          icon: Icons.message,
          onTap: () {
            setState(() {
              showTickets = false;
            });
          },
        ),
      ],
    ),
  );
}

Widget _buildAnimatedToggleButton({
  required bool isSelected,
  required String label,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color.fromARGB(255, 20, 67, 168), Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Colors.grey, Colors.grey],
              ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.black54,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ],
      ),
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
            DocumentSnapshot ticketDoc = tickets[index];
            var ticket = ticketDoc.data() as Map<String, dynamic>;

            String titre = ticket['Titre'] ?? 'Titre non défini';
            String description =
                ticket['Description'] ?? 'Description non définie';
            String categorie = ticket['categorie'] ?? 'Catégorie non définie';
            String apprenantId =
                ticket['ApprenantId'] ?? 'ID Apprenant non défini';
            String etat = ticket['Etat'] ?? 'Statut inconnu';

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
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TicketDetailPage(ticketData: ticket),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.description,
                                        color: Color.fromARGB(255, 20, 67, 168)),
                                       const SizedBox(width: 8),
                                    const SizedBox(width: 5),
                                    Text(
                                      titre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color.fromARGB(255, 20, 67, 168),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: etat.toLowerCase() == 'résolu'
                                      ? Colors.green[100]
                                      : etat.toLowerCase() == 'en cours'
                                          ? Colors.yellow[100]
                                          : Colors.red[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  etat,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: etat.toLowerCase() == 'résolu'
                                        ? Colors.green[800]
                                        : etat.toLowerCase() == 'en cours'
                                            ? Colors.orange[800]
                                            : Colors.red[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.description,
                                 color: Colors.black54, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Description:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 22.0),
                            child: Text(
                              description,
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.category,
                                  color: Colors.black54, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Catégorie: $categorie',
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.black54, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Apprenant: $apprenantNom',
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.send,
                                color: Color.fromARGB(255, 20, 67, 168),
                              ),
                              onPressed: () {
                                if (etat.toLowerCase() == 'résolu') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Ce ticket a déjà été résolu.'),
                                    ),
                                  );
                                } else {
                                  _setTicketInProgress(ticketDoc, context);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }




// Méthode pour mettre le ticket à "En cours" et naviguer vers le formulaire de réponse
  void _setTicketInProgress(DocumentSnapshot ticket, BuildContext context) {
    FirebaseFirestore.instance.collection('tickets').doc(ticket.id).update({
      'Etat': 'En cours', // Mise à jour du statut à 'En cours'
    }).then((_) {
      Navigator.pushNamed(
        context,
        '/response_form',
        arguments: ticket,
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour du statut du ticket.'),
        ),
      );
    });
  }


// Méthode pour démarrer une réponse
  void _startResponse(BuildContext context, DocumentSnapshot ticket) {
    // Mettre à jour le statut du ticket à 'Résolu' lors de la soumission
    FirebaseFirestore.instance.collection('tickets').doc(ticket.id).update({
      'Etat': 'Résolu', // Mise à jour du statut
    }).then((_) {
      Navigator.pop(context); // Ferme le formulaire après soumission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réponse soumise avec succès.')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la soumission de la réponse.')),
      );
    });
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
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ResponseDetailPage(responseData: response),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.question_answer_rounded,
                                    color: Color.fromARGB(255, 20, 67, 168)),
                                   const SizedBox(width: 8),
                                const SizedBox(width: 5),
                                Text(
                                  titre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 20, 67, 168),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (categorie.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: categorie == 'Technique'
                                    ? Colors.blue[100]
                                    : categorie == 'Pédagogique'
                                        ? Colors.green[100]
                                        : Colors.orange[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    categorie == 'Technique'
                                        ? Icons.build
                                        : categorie == 'Pédagogique'
                                            ? Icons.school
                                            : Icons.category,
                                    size: 16,
                                    color: categorie == 'Technique'
                                        ? Colors.blue[800]
                                        : categorie == 'Pédagogique'
                                            ? Colors.green[800]
                                            : Colors.orange[800],
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    categorie,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: categorie == 'Technique'
                                          ? Colors.blue[800]
                                          : categorie == 'Pédagogique'
                                              ? Colors.green[800]
                                              : Colors.orange[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.description,
                            color: Colors.black54, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Description:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 22.0),
                        child: Text(
                          description,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (date != null)
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.black54, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Date: ${date.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 14),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenuButton<String>(
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
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


class ResponseDetailPage extends StatelessWidget {
  final Map<String, dynamic> responseData;

  const ResponseDetailPage({Key? key, required this.responseData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Réponse'),
        backgroundColor: const Color.fromARGB(255, 20, 67, 168),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    icon: Icons.title,
                    label: 'Titre',
                    value: responseData['titre'] ?? 'Titre non défini',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    icon: Icons.description,
                    label: 'Description',
                    value: responseData['description'] ?? 'Description non définie',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    icon: Icons.category,
                    label: 'Catégorie',
                    value: responseData['categorie'] ?? 'Catégorie non définie',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: (responseData['Date'] as Timestamp?)?.toDate().toString() ?? 'Date non définie',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color.fromARGB(255, 20, 67, 168)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class TicketDetailPage extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const TicketDetailPage({Key? key, required this.ticketData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Ticket'),
        backgroundColor: const Color.fromARGB(255, 20, 67, 168),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    icon: Icons.title,
                    label: 'Titre',
                    value: ticketData['Titre'] ?? 'Titre non défini',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    icon: Icons.description,
                    label: 'Description',
                    value: ticketData['Description'] ?? 'Description non définie',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    icon: Icons.category,
                    label: 'Catégorie',
                    value: ticketData['categorie'] ?? 'Catégorie non définie',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    icon: Icons.info_outline,
                    label: 'Statut',
                    value: ticketData['Etat'] ?? 'Statut non défini',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: (ticketData['Date'] as Timestamp?)?.toDate().toString() ?? 'Date non définie',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color.fromARGB(255, 20, 67, 168)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


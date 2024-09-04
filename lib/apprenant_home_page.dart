import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApprenantHomePage extends StatefulWidget {
  const ApprenantHomePage({Key? key}) : super(key: key);

  @override
  _ApprenantHomePageState createState() => _ApprenantHomePageState();
}

class _ApprenantHomePageState extends State<ApprenantHomePage> {
  final String apprenantId = FirebaseAuth.instance.currentUser!.uid;
  bool showTickets = true;
  String? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Apprenant',
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
          _buildStaticCategoryFilter(),
          _buildToggleButtons(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: showTickets ? _buildTicketList() : _buildResponseList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/submit_ticket');
        },
        backgroundColor: const Color.fromARGB(255, 20, 67, 168),
        child: const Icon(Icons.add, color: Colors.white),
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

  Widget _buildStaticCategoryFilter() {
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
      stream: _selectedCategory == null
          ? FirebaseFirestore.instance
              .collection('tickets')
              .where('ApprenantId', isEqualTo: apprenantId)
              .snapshots()
          : FirebaseFirestore.instance
              .collection('tickets')
              .where('ApprenantId', isEqualTo: apprenantId)
              .where('categorie', isEqualTo: _selectedCategory)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final tickets = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data['Titre']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery) ||
              data['Description']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery);
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
            String etat = ticket['Etat'] ?? 'Statut inconnu';

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
                    Text('Statut: $etat'),
                  ],
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
  }

  Widget _buildResponseList() {
    return FutureBuilder<List<String>>(
      future: _getApprenantTickets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucune réponse trouvée.'));
        }

        final ticketIds = snapshot.data!;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reponseticket')
              .where('ticketId', whereIn: ticketIds)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final responses = snapshot.data!.docs.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return data['titre']
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery) ||
                  data['description']
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery);
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
                String categorie =
                    response['categorie'] ?? 'Catégorie non définie';
                DateTime? date = (response['Date'] as Timestamp?)?.toDate();

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
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
      },
    );
  }

  Future<List<String>> _getApprenantTickets() async {
    final ticketDocs = await FirebaseFirestore.instance
        .collection('tickets')
        .where('ApprenantId', isEqualTo: apprenantId)
        .get();
    return ticketDocs.docs.map((doc) => doc.id).toList();
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
      },
    );
  }
}

class TicketDetailPage extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const TicketDetailPage({Key? key, required this.ticketData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Titre: ${ticketData['Titre']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Description: ${ticketData['Description']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Catégorie: ${ticketData['categorie']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Statut: ${ticketData['Etat']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text(
                'Date: ${(ticketData['Date'] as Timestamp?)?.toDate().toString() ?? 'Date non définie'}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class ResponseDetailPage extends StatelessWidget {
  final Map<String, dynamic> responseData;

  const ResponseDetailPage({Key? key, required this.responseData})
      : super(key: key);

  Future<void> _requestToContactFormateur(BuildContext context) async {
    String apprenantId = FirebaseAuth.instance.currentUser!.uid;
    String formateurId = responseData['formateurId'];
    String ticketId = responseData['ticketId'];

    // Envoyer la demande de contact au formateur, sans `groupId`
    await FirebaseFirestore.instance.collection('invitations').add({
      'apprenantId': apprenantId,
      'formateurId': formateurId,
      'ticketId': ticketId,
      'status': 'pending', // Statut de la demande
      'timestamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demande de contact envoyée au formateur.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Réponse'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Titre: ${responseData['titre']}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Description: ${responseData['description']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text('Catégorie: ${responseData['categorie']}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text(
                'Date: ${(responseData['Date'] as Timestamp?)?.toDate().toString() ?? 'Date non définie'}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _requestToContactFormateur(context),
              child: const Text('Contacter le Formateur'),
            ),
          ],
        ),
      ),
    );
  }
}

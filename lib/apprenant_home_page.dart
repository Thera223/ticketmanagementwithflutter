import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestionticket/main.dart';
import 'package:provider/provider.dart';

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
  int _currentIndex = 0;

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
        title: const Text('Accueil Apprenant',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/submit_ticket');
        },
        backgroundColor: const Color.fromARGB(255, 20, 67, 168),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onItemTapped(index, userRole),
      ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.assignment,
                                  color: Color.fromARGB(255, 20, 67, 168)),
                              const SizedBox(width: 8),
                              Text(
                                titre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 20, 67, 168),
                                ),
                              ),
                            ],
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
                          Flexible(child: Text('Description: $description')),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.category,
                              color: Colors.black54, size: 18),
                          const SizedBox(width: 6),
                          Text('Catégorie: $categorie'),
                        ],
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
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.message,
                                      color: Color.fromARGB(255, 20, 67, 168)),
                                  const SizedBox(width: 8),
                                  Text(
                                    titre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 20, 67, 168),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Pédagogique',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
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
                              Flexible(
                                  child: Text('Description: $description')),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.category,
                                  color: Colors.black54, size: 18),
                              const SizedBox(width: 6),
                              Text('Catégorie: $categorie'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.date_range,
                                  color: Colors.black54, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                  'Date: ${date != null ? date.toString() : 'Date non définie'}'),
                            ],
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

  Future<List<String>> _getApprenantTickets() async {
    final ticketDocs = await FirebaseFirestore.instance
        .collection('tickets')
        .where('ApprenantId', isEqualTo: apprenantId)
        .get();
    return ticketDocs.docs.map((doc) => doc.id).toList();
  }
}

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", 0),
            _buildNavItem(Icons.chat, "Chat", 1),
            _buildNavItem(Icons.notifications, "Notifications", 2),
            _buildNavItem(Icons.person, "Profil", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = widget.currentIndex == index;
    return GestureDetector(
      onTap: () {
        widget.onTap(index);
        _controller.forward(from: 0);
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: isSelected ? 1.2 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromARGB(255, 20, 67, 168)
                        : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(icon,
                      color: isSelected ? Colors.white : Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? const Color.fromARGB(255, 20, 67, 168)
                        : Colors.black54,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
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


class ResponseDetailPage extends StatelessWidget {
  final Map<String, dynamic> responseData;

  const ResponseDetailPage({Key? key, required this.responseData})
      : super(key: key);

  Future<void> _requestToContactFormateur(BuildContext context) async {
    String apprenantId = FirebaseAuth.instance.currentUser!.uid;
    String formateurId = responseData['formateurId'];
    String ticketId = responseData['ticketId'];

    await FirebaseFirestore.instance.collection('invitations').add({
      'apprenantId': apprenantId,
      'formateurId': formateurId,
      'ticketId': ticketId,
      'status': 'pending',
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
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _requestToContactFormateur(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        backgroundColor: const Color.fromARGB(255, 20, 67, 168),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Contacter le Formateur',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
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

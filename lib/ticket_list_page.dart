import 'package:flutter/material.dart';

class TicketManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Tickets'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Liste des Tickets',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tableau des tickets
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Titre')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Catégorie')),
                    DataColumn(label: Text('Statut')),
                  ],
                  rows: [
                    _buildTicketRow(
                      'Ticket 1',
                      'Problème d\'accès',
                      '01/09/2024',
                      'jane@microsoft.com',
                      'Pédagogique',
                      'En attente',
                    ),
                    _buildTicketRow(
                      'Ticket 2',
                      'Erreur technique',
                      '02/09/2024',
                      'floydey@yahoo.com',
                      'Technique',
                      'En cours',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Liste des Réponses
            const Text(
              'Réponses aux Tickets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Titre du Ticket')),
                    DataColumn(label: Text('Réponse')),
                    DataColumn(label: Text('Date de Réponse')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Catégorie')),
                    DataColumn(label: Text('Statut')),
                  ],
                  rows: [
                    _buildResponseRow(
                      'Ticket 1',
                      'Réponse à la demande d\'accès',
                      '04/09/2024',
                      'admin@domain.com',
                      'Pédagogique',
                      'Résolu',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour construire une ligne de ticket
  DataRow _buildTicketRow(String title, String description, String date,
      String email, String category, String status) {
    return DataRow(cells: [
      DataCell(Text(title)),
      DataCell(Text(description)),
      DataCell(Text(date)),
      DataCell(Text(email)),
      DataCell(Text(category)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    ]);
  }

  // Méthode pour construire une ligne de réponse
  DataRow _buildResponseRow(String ticketTitle, String response, String date,
      String email, String category, String status) {
    return DataRow(cells: [
      DataCell(Text(ticketTitle)),
      DataCell(Text(response)),
      DataCell(Text(date)),
      DataCell(Text(email)),
      DataCell(Text(category)),
      DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    ]);
  }

  // Fonction pour déterminer la couleur de l'état
  Color _getStatusColor(String status) {
    switch (status) {
      case 'En attente':
        return Colors.red;
      case 'En cours':
        return Colors.orange;
      case 'Résolu':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

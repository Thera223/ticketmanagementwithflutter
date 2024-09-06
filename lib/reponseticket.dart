import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResponseForm extends StatefulWidget {
  final DocumentSnapshot ticket;

  const ResponseForm({Key? key, required this.ticket}) : super(key: key);

  @override
  _ResponseFormState createState() => _ResponseFormState();
}

class _ResponseFormState extends State<ResponseForm> {
  final TextEditingController _descriptionController = TextEditingController();

  // Méthode pour obtenir l'ID du formateur connecté
  String get _formateurId {
    final User? user = FirebaseAuth.instance.currentUser;
    return user != null ? user.uid : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Répondre au Ticket'),
        backgroundColor: const Color.fromARGB(255, 20, 67, 168),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Titre du Ticket',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                widget.ticket['Titre'] ?? 'Titre non défini',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Description de la Réponse',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 8, // Augmente la taille de la zone de texte
                decoration: const InputDecoration.collapsed(
                    hintText: 'Entrez votre réponse ici...'),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _submitResponse(widget.ticket.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 20, 67, 168),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Soumettre',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitResponse(String ticketId) async {
    try {
      await FirebaseFirestore.instance.collection('reponseticket').add({
        'ticketId': ticketId,
        'formateurId': _formateurId,
        'Date': Timestamp.now(),
        'description': _descriptionController.text.trim(),
        'titre': widget.ticket['Titre'],
        'categorie': widget.ticket['categorie'],
      });

      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .update({'Etat': 'résolu'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réponse soumise avec succès !')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la soumission de la réponse : $e')),
      );
    }
  }
}

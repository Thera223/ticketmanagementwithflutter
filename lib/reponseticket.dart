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
    return user != null
        ? user.uid
        : ''; // Retourne l'ID de l'utilisateur s'il est connecté, sinon une chaîne vide
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Répondre au Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(
                  text: widget.ticket['Titre'] ?? 'Titre non défini'),
              decoration: const InputDecoration(labelText: 'Titre'),
              enabled:
                  false, // Désactiver le champ pour ne pas permettre l'édition
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration:
                  const InputDecoration(labelText: 'Description de la réponse'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _submitResponse(widget.ticket.id);
              },
              child: const Text('Soumettre'),
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
        'formateurId': _formateurId, // Utilisez l'ID du formateur connecté
        'Date': Timestamp.now(),
        'description': _descriptionController.text.trim(),
        'titre': widget.ticket['Titre'], // Titre défini par l'apprenant
        'categorie':
            widget.ticket['categorie'], // Catégorie définie par l'apprenant
      });

      // Mettre à jour le statut du ticket
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .update({'Etat': 'résolu'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réponse soumise avec succès !')),
      );

      Navigator.pop(context); // Retourner à la page précédente
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la soumission de la réponse : $e')),
      );
    }
  }
}

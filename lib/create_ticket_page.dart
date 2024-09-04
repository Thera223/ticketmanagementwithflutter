import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubmitTicketForm extends StatefulWidget {
  const SubmitTicketForm({Key? key}) : super(key: key);

  @override
  State<SubmitTicketForm> createState() => _SubmitTicketFormState();
}

class _SubmitTicketFormState extends State<SubmitTicketForm> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Technique'; // Catégorie sélectionnée par défaut

  // Méthode pour obtenir l'ID de l'utilisateur connecté
  String get _userId {
    final User? user = FirebaseAuth.instance.currentUser;
    return user != null ? user.uid : ''; // Retourne l'ID de l'utilisateur s'il est connecté, sinon une chaîne vide
  }

  Future<void> _submitTicket() async {
    if (_userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('tickets').add({
        'ApprenantId': _userId, // Utilisez l'ID de l'apprenant connecté
        'Titre': _titreController.text.trim(),
        'Description': _descriptionController.text.trim(),
        'categorie': _selectedCategory,
        'Etat': 'en attente',
        'Date': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket soumis avec succès !')),
      );

      Navigator.pop(context); // Retourner à la page précédente
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la soumission du ticket : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titreController,
              decoration: const InputDecoration(labelText: 'Titre'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: ['Technique', 'Pédagogique', 'Autres']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Catégorie'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTicket,
              child: const Text('Soumettre'),
            ),
          ],
        ),
      ),
    );
  }
}

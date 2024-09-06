import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Importez le package intl pour le formatage de l'heure

class ChatPage extends StatefulWidget {
  final String groupId;
  const ChatPage({Key? key, required this.groupId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final String senderId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('groupes_de_chat')
        .doc(widget.groupId)
        .collection('messages')
        .add({
      'message': _messageController.text,
      'senderId': senderId,
      'timestamp': Timestamp.now(),
    });

    _messageController.clear();
  }

  Future<String> _getUserName(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['name'] ?? 'Utilisateur';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion de Groupe'),
        backgroundColor: const Color.fromARGB(255, 20, 67, 168),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groupes_de_chat')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message =
                        messages[index].data() as Map<String, dynamic>;
                    String sender = message['senderId'] ?? 'Utilisateur';
                    String content = message['message'] ?? '';
                    Timestamp timestamp = message['timestamp'];

                    bool isCurrentUser = sender == senderId;
                    String formattedTime =
                        DateFormat('HH:mm').format(timestamp.toDate());

                    return FutureBuilder<String>(
                      future: _getUserName(sender),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        String senderName = snapshot.data ?? 'Utilisateur';

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: isCurrentUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!isCurrentUser) ...[
                                CircleAvatar(
                                  radius: 15,
                                  child: Text(
                                    senderName[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: isCurrentUser
                                        ? Colors.blue[100]
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(12),
                                      topRight: const Radius.circular(12),
                                      bottomLeft: isCurrentUser
                                          ? const Radius.circular(12)
                                          : Radius.zero,
                                      bottomRight: isCurrentUser
                                          ? Radius.zero
                                          : const Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isCurrentUser
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (!isCurrentUser)
                                        Text(
                                          senderName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      const SizedBox(height: 5),
                                      Text(
                                        content,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        formattedTime,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isCurrentUser)
                                const SizedBox(width: 40), // Space for Avatar
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Entrez un message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 20, 67, 168),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

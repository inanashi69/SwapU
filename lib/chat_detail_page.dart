import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.otherUserId,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _controller = TextEditingController();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  String otherUserName = '';
  String? otherUserPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadOtherUserData();
  }

  void _loadOtherUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUserId)
        .get();

    if (doc.exists) {
      setState(() {
        otherUserName = doc['displayName'] ?? 'Pengguna';
        otherUserPhotoUrl = doc['photoUrl'];
      });
    } else {
      setState(() {
        otherUserName = 'Pengguna';
        otherUserPhotoUrl = null;
      });
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final messageData = {
      'text': text,
      'senderId': currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    };

    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

    await chatRef.collection('messages').add(messageData);

    await chatRef.update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images/${widget.chatId}/$fileName');

      await storageRef.putFile(file);
      final imageUrl = await storageRef.getDownloadURL();

      final chatRef =
          FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

      final imageMessage = {
        'imageUrl': imageUrl,
        'senderId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'image',
      };

      await chatRef.collection('messages').add(imageMessage);

      await chatRef.update({
        'lastMessage': '[Gambar]',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    final dt = (timestamp as Timestamp).toDate();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: otherUserPhotoUrl != null &&
                      otherUserPhotoUrl!.isNotEmpty
                  ? NetworkImage(otherUserPhotoUrl!)
                  : null,
              backgroundColor: Colors.grey,
              child: otherUserPhotoUrl == null ||
                      otherUserPhotoUrl!.isEmpty
                  ? const Icon(Icons.person, color: Colors.black, size: 18)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              otherUserName.isEmpty ? 'Memuat...' : otherUserName,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.yellow));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == currentUserId;
                    final isImage = msg['type'] == 'image';

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        constraints: const BoxConstraints(maxWidth: 250),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.yellow : Colors.white12,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isImage)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  msg['imageUrl'],
                                  fit: BoxFit.cover,
                                  width: 200,
                                ),
                              )
                            else
                              Text(
                                msg['text'] ?? '',
                                style: TextStyle(
                                  color:
                                      isMe ? Colors.black : Colors.white,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(msg['timestamp']),
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    isMe ? Colors.black54 : Colors.white54,
                              ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.yellow),
                  onPressed: _sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.yellow),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

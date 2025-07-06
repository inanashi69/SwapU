import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Anda belum login.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final currentUserId = currentUser.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pesan'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: currentUserId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Firestore error: ${snapshot.error}');
            return const Center(
              child: Text(
                'Terjadi kesalahan',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.yellow),
            );
          }

          final chats = snapshot.data?.docs ?? [];

          if (chats.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada percakapan.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final users = List<String>.from(chat['users']);
              final otherUserId = users.firstWhere((uid) => uid != currentUserId);
              final lastMessage = chat['lastMessage'] ?? '';
              final chatId = chat.id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final displayName = userData['displayName'] ?? 'Tanpa Nama';
                  final photoUrl = userData['photoUrl'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      backgroundColor: Colors.grey,
                      child: photoUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.black)
                          : null,
                    ),
                    title: Text(
                      displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      lastMessage,
                      style: const TextStyle(color: Colors.white54),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.yellow),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chatDetail',
                        arguments: {
                          'chatId': chatId,
                          'otherUserId': otherUserId,
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

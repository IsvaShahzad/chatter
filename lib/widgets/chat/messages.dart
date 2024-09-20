import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

class Messages extends StatelessWidget {
  final String selectedUserId;
  final String currentUserId;

  Messages({required this.selectedUserId, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .doc(generateChatId(currentUserId, selectedUserId))
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, chatSnapshot) {
        print("Chat Snapshot: ${chatSnapshot.data?.docs}");

        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final chatDocs = chatSnapshot.data?.docs ?? [];
        print("Chat Docs: $chatDocs");
        print("Chat Docs Length: ${chatDocs?.length}");

        return chatDocs.isEmpty
            ? Center(
          child: Text('No messages available.'),
        )
            : ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (context, index) {
            final text = chatDocs[index]['text'] ?? "";
            final chatURL = chatDocs[index]['imageUrl'] ?? "";
            final isCurrentUser = chatDocs[index]['userId'] == FirebaseAuth.instance.currentUser?.uid;
            // final username = chatDocs[index]['username'] ?? "";
            // final userImage = chatDocs[index]['userImage'] ?? "";
            print(isCurrentUser);

            if (text.isNotEmpty) {
              return MessageBubble(
                text,
                isCurrentUser,
                // username,
                // userImage,
                key: ValueKey(chatDocs[index].id),
                chatURL: chatURL,

              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}



String generateChatId(String userId1, String userId2) {
  List<String> userIds = [userId1, userId2];
  userIds.sort();
  String chatId = userIds.join();
  print('Generated Chat ID: $chatId');
  return chatId;
}



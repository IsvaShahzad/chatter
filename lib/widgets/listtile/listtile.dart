import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContactsListTile extends StatelessWidget {
  final String phone;
  final currentUserData;

  const ContactsListTile({required this.phone, required this.currentUserData});

  @override
  Widget build(BuildContext context) {


    return Card(
      margin: EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          phone,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        leading: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .where('phone', isEqualTo: phone)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircleAvatar(
                backgroundColor: Colors.blue,
              );
            } else {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                var imageUrl = snapshot.data!.docs[0]['image_url'];
                return CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                );
              } else {
                return CircleAvatar(
                  backgroundColor: Colors.blue,
                );
              }
            }
          },
        ),
        onTap: () => _startChat(
          phone,
          'imageUrl',
        ),
      ),
    );
  }

  void _startChat(String phone, String imageUrl) {
    print('Selected User Phone: $phone');
    print('Current User Phone: ${currentUserData['phone']}');
    // Navigate to the chat screen or perform any other action
  }
}
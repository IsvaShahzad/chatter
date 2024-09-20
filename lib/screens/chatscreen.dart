import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/chat/messages.dart';
import '../widgets/chat/new_messages.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> selectedUserData;
  final Map<String, dynamic> currentUserData;

  ChatScreen({required this.selectedUserData, required this.currentUserData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late User? user;
  late Map<String, dynamic> userData;
  late String selectedUserEmail;
  late String currentUserEmail;

  @override
  void initState() {
    super.initState();
    // Retrieve the current user and user data when the screen initializes
    user = FirebaseAuth.instance.currentUser;
    retrieveUserData();
    selectedUserEmail = widget.selectedUserData['phone'] ?? '';
    currentUserEmail = widget.currentUserData['phone'] ?? '';
  }

  // Retrieve user data based on the current user's UID
  void retrieveUserData() async {
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('otp_users')
          .doc(user!.uid)
          .get();

      setState(() {
        userData = userDoc.data()!;
      });
    }
  }

  // Logout logic
  // Future<void> _signOut() async {
  // await FirebaseAuth.instance.signOut();
  // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AuthScreen()));

  @override
  Widget build(BuildContext context) {
    String selectedUserId = widget.selectedUserData['phone'] ?? '';
    String currentUserId = widget.currentUserData['phone'] ?? '';

    print('Selected the User ID: $selectedUserId');
    print('Current User ID: $currentUserId');

    // Add this line to print the selected user ID

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedUserEmail),
        actions: [
          DropdownButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.exit_to_app),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text('Logout ')
                    ],
                  ),
                ),
                value: 'logout',
              ),
            ],
            onChanged: (itemIdentifier) async {
              if (itemIdentifier == 'logout') {
                // await _signOut();
              }
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Messages(
                  selectedUserId: selectedUserId, currentUserId: currentUserId),
            ),
            NewMessage(
                selectedUserData: widget.selectedUserData,
                currentUserData: widget.currentUserData),
          ],
        ),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ChatScreen.dart';
import 'Login.dart';

class SavedContactsScreen extends StatefulWidget {
  // final String currentUser;
  User? currentUser = FirebaseAuth.instance.currentUser;

  //
  // const SavedContactsScreen({super.key, required this.currentUser});
  @override
  _SavedContactsScreenState createState() => _SavedContactsScreenState();
}

class _SavedContactsScreenState extends State<SavedContactsScreen> {
  bool isAddContactOpen = false;
  TextEditingController phoneController = TextEditingController();


  void _toggleAddContact() {
    setState(() {
      isAddContactOpen = !isAddContactOpen;
    });
  }

  void _addContact() async {
    String phone = phoneController.text.trim();

    // Check if the phone number exists in Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('otp_users') // Replace with your actual user collection name
        .where('phone', isEqualTo: phone)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Phone number exists, check if it's already a contact for the current user
      bool isAlreadyContact = await FirebaseFirestore.instance
          .collection('savedContacts')
          .where('userId', isEqualTo: user!.uid) // Filter by user's UID
          .where('phone', isEqualTo: phone)
          .get()
          .then((snapshot) => snapshot.docs.isNotEmpty);

      if (!isAlreadyContact) {
        // Phone number is not already a contact, add it to the savedContacts collection
        await FirebaseFirestore.instance.collection('savedContacts').add({
          'userId': user!.uid, // Associate the contact with the user's UID
          'phone': phone,
        });

        // Display a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Phone Contact Added: $phone'),
        ));
      } else {
        // Phone number is already a contact for the current user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Contact Already Exists: $phone'),
        ));
      }
    } else {
      // Phone number does not exist
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Phone does not exist'),
      ));
    }

    // Clear the text field
    phoneController.clear();

    // Close the add contact menu
    _toggleAddContact();
  }

// Declare variables to hold user and selected user data
  late User? user;
  late Map<String, dynamic> currentUserData = {}; // Provide a default value
  // late Map<String, dynamic> selectedUserData; // Added this line

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    retrieveUserData();
  }

  void retrieveUserData() async {
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('otp_users')
          .doc(user!.uid)
          .get();

      setState(() {
        currentUserData = {
          'phone': userDoc['phone'] ?? '', // Use null-aware operator
        };
      });

      print('Current User is: ${currentUserData['phone']}');
    }
  }
  void _startChat(String phone) async {
    print('Selected User Phone: $phone');
    print('Current User Phone: ${currentUserData['phone']}');

    // Check if the selected contact belongs to the current user
    bool isContactBelongsToCurrentUser = await FirebaseFirestore.instance
        .collection('savedContacts')
        .where('userId', isEqualTo: user!.uid) // Filter by user's UID
        .where('phone', isEqualTo: phone)
        .get()
        .then((snapshot) => snapshot.docs.isNotEmpty);

    if (isContactBelongsToCurrentUser) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            selectedUserData: {'phone': phone},
            currentUserData: currentUserData,
          ),
        ),
      );
    } else {
      // Show a message indicating that the selected contact doesn't belong to the current user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('You don\'t have access to this contact!'),
      ));
    }
  }
  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: 'Enter contact phone',
                    ),
                  ),
                  SizedBox(height: 11),
                  ElevatedButton(
                    onPressed: () {
                      _addContact();
                      Navigator.pop(
                          context); // Close the dialog after adding contact
                      _toggleAddContact(); // Toggle the contact adding field
                    },
                    child: Text('Add Contact'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.center,
          child: Text('Contact List'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (isAddContactOpen)
            Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            hintText: 'Enter contact Phone',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: _addContact,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('otp_users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                List<DocumentSnapshot>? documents =
                snapshot.data?.docs as List<DocumentSnapshot>?;

                if (documents == null || documents.isEmpty) {
                  return Center(
                    child: Text('No contacts available.'),
                  );
                }

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    return Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        child:
                        ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            documents[index]['phone'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          leading: FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('otp_users')
                                .where('phone', isEqualTo: documents[index]['phone'])
                                .get(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircleAvatar(
                                  backgroundColor: Colors.red,
                                );
                              } else {
                                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                  // var imageUrl = snapshot.data!.docs[0]['image_url'];
                                  return CircleAvatar(
                                    // backgroundImage: NetworkImage(imageUrl),
                                  );
                                } else {
                                  return CircleAvatar(
                                    backgroundColor: Colors.red,
                                  );
                                }
                              }
                            },
                          ),
                          onTap: () {
                            _startChat(documents[index]['phone']);
                            retrieveUserData();
                          },
                        ));
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 55),
            child: FloatingActionButton(
              onPressed: () {
                _showAddContactDialog();
              },
              child: Icon(isAddContactOpen ? Icons.close : Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
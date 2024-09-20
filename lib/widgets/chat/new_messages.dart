import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class NewMessage extends StatefulWidget {
  final Map<String, dynamic> selectedUserData;
  final Map<String, dynamic> currentUserData;
  List<File> selectedImages = []; // List of selected images
  final picker = ImagePicker(); // Instance of Image picker

  NewMessage({required this.selectedUserData, required this.currentUserData});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  late String _enteredMessage = '';
  String? _downloadURL; // Declare _downloadURL

  @override
  void initState() {
    super.initState();
    _enteredMessage = '';
  }

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = await FirebaseAuth.instance.currentUser;

    try {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      if (userData != null) {
        await FirebaseFirestore.instance
            .collection('chat')
            .doc(generateChatId(widget.currentUserData['phone'],
            widget.selectedUserData['phone']))
            .collection('messages')
            .add({
          'text': _enteredMessage,
          'imageUrl': _downloadURL,
          'createdAt': FieldValue.serverTimestamp(),
          'userId': user!.uid,
          // 'username': userData['username'],
          // 'userImage': userData['image_url'],
        });

        print('Message added to Firestore successfully!');
        print(_enteredMessage);
        print('Chat image URL is $_downloadURL');
      }

      setState(() {
        _downloadURL = null;
      });

      _controller.clear();
    } catch (error) {
      print('Error adding message to Firestore: $error');
    }
  }

  void _sendImage() async {
    // Use ImagePicker to select an image from the gallery
    final pickedFiles = await widget.picker.pickMultiImage(
      imageQuality: 100,
      maxHeight: 500,
      maxWidth: 500,
    );

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      print('Selected ${pickedFiles.length} image(s)');

      for (var i = 0; i < pickedFiles.length; i++) {
        File imageFile = File(pickedFiles[i].path);
        String fileName =
        DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference =
        FirebaseStorage.instance.ref().child("ChatImages/$fileName");

        UploadTask uploadTask = storageReference.putFile(imageFile);

        await uploadTask.whenComplete(() async {
          String downloadURL = await storageReference.getDownloadURL();
          print("Image uploaded successfully. Download URL: $downloadURL");

          // Store the downloadURL in the list or use it as needed
          widget.selectedImages.add(imageFile); // Add selected image to the list
          // If you need to use it in _sendMessage, set it to _downloadURL
          setState(() {
            _downloadURL = downloadURL;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8.0),
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          if (_downloadURL != null)
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_downloadURL!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(labelText: 'Send a message ...'),
                  onChanged: (value) {
                    setState(() {
                      _enteredMessage = value;
                    });
                  },
                ),
              ),
              IconButton(
                color: Theme.of(context).primaryColor,
                icon: Icon(Icons.attach_file),
                onPressed: _sendImage,
              ),
              IconButton(
                color: Theme.of(context).primaryColor,
                icon: Icon(Icons.send),
                onPressed:
                _enteredMessage.trim().isEmpty ? null : _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String generateChatId(String userId1, String userId2) {
    List<String> userIds = [userId1, userId2];
    userIds.sort();
    String chatId = userIds.join();
    print('Generated Chat ID: $chatId');
    return chatId;
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'OTP.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _controller = TextEditingController();

  // final CollectionReference usersCollection =
  //     FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Login Page!'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ' Phone Authentication\nUsing OTP Verification',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            SizedBox(height: 40.0),
            Text('Format: [subscriber number]'),
            SizedBox(height: 40.0),
            TextField(
              cursorColor: Colors.black,
              style: TextStyle(fontSize: 18.0, color: Colors.black),
              maxLength: 10,
              keyboardType: TextInputType.number,
              controller: _controller,
              decoration: InputDecoration(
                fillColor: Colors.orange.withOpacity(0.1),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                labelText: 'Phone Number',
                labelStyle: TextStyle(
                  fontSize: 16.0,
                ),
                prefixIcon: Icon(Icons.phone),
                prefix: Padding(
                  padding: EdgeInsets.all(4),
                  child: Text('+92'),
                ),
              ),
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () async {


                // Navigate to OTP page with the entered phone number
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OtpPage(_controller.text),
                  ),
                );
              },
              child: Text('Verify', style: TextStyle(fontSize: 17.0)),
            ),
          ],
        ),
      ),
    );
  }
}
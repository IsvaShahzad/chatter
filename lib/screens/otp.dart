import 'package:chatterapp/screens/saved_contact.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  OtpPage(this.phone);

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _verificationID;
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('OTP Verification Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Center(
              child: Text(
                'Verify +92-${widget.phone}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: PinInputTextField(
              pinLength: 6,
              decoration: UnderlineDecoration(
                textStyle: TextStyle(fontSize: 25.0, color: Colors.black),
                colorBuilder: PinListenColorBuilder(
                  Colors.blueGrey, // Regular color
                  Colors.green, // Highlight color
                ),
              ),
              controller: _pinController,
              autoFocus: true,
              textInputAction: TextInputAction.done,
              onSubmit: (pin) async {
                try {
                  await FirebaseAuth.instance
                      .signInWithCredential(
                    PhoneAuthProvider.credential(
                      verificationId: _verificationID!,
                      smsCode: pin,
                    ),
                  )
                      .then((value) async {
                    if (value.user != null) {
                      // Add user data to 'otp.users' collection
                      await FirebaseFirestore.instance
                          .collection('otp_users')
                          .doc(value.user!.uid)
                          .set({
                        'phone': '+92${widget.phone}',
                        'userId': value.user!.uid,
                      });

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SavedContactsScreen()),
                            (route) => false,
                      );
                    }
                  });
                } catch (e) {
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid OTP!')),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+92${widget.phone}',
      verificationCompleted: (PhoneAuthCredential authCredential) async {
        await FirebaseAuth.instance
            .signInWithCredential(authCredential)
            .then((value) async {
          if (value.user != null) {
            // Add user data to 'otp.users' collection
            await FirebaseFirestore.instance
                .collection('otp_users')
                .doc(value.user!.uid)
                .set({
              'phone': '+92${widget.phone}',
              'userId': value.user!.uid,
            });

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SavedContactsScreen()),
                  (route) => false,
            );
          }
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeAutoRetrievalTimeout: (String verID) {
        setState(() {
          _verificationID = verID;
        });
      },
      timeout: Duration(seconds: 11),
      codeSent: (String verificationId, int? forceResendingToken) {
        setState(() {
          _verificationID = verificationId;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }
}
import 'package:app7/homepage.dart';
import 'package:app7/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => WrapperState();
}

class WrapperState extends State<Wrapper> {
  bool _isLoading = true;
  bool _isCR = false;

  @override
  void initState() {
    super.initState();
    _checkCRStatus();
  }

  Future<void> _checkCRStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _isCR = userDoc['isCR'] ?? false;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isCR = false;
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error checking CR status: $e");
        setState(() {
          _isCR = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            return Homepage(isCR: _isCR);
          } else {
            return const Login();
          }
        },
      ),
    );
  }
}
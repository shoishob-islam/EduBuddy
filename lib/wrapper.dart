import 'package:app7/homepage.dart';
import 'package:app7/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => WrapperState();
}

class WrapperState extends State<Wrapper> {
  bool _isLoading = true;
  bool _isCR = false;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    print('Wrapper initState called');
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _setupAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      print('Auth state changed in listener - user: ${user?.email ?? 'null'}');
      if (user != null) {
        _checkCRStatus();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _checkCRStatus() async {
    print('Checking CR status...');
    User? user = FirebaseAuth.instance.currentUser;
    print('Current user: ${user?.email ?? 'null'}');

    if (user != null) {
      try {
        print('Fetching user document from Firestore...');
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        print('Firestore document fetched');

        if (userDoc.exists) {
          setState(() {
            _isCR = userDoc['isCR'] ?? false;
            _isLoading = false;
          });
          print('CR status set, loading complete');
        } else {
          // For new users, set default values
          bool isCR = (user.email == 'test1@gmail.com');
          setState(() {
            _isCR = isCR;
            _isLoading = false;
          });
          print('New user detected, CR status set to $isCR');
        }
      } catch (e) {
        debugPrint("Error checking CR status: $e");
        setState(() {
          _isCR = false;
          _isLoading = false;
        });
        print('Error occurred, loading complete');
      }
    } else {
      print('No user found, setting loading to false');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Wrapper build called, isLoading: $_isLoading');
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      print('Building Homepage for user: ${currentUser.email}');
      return Homepage(isCR: _isCR);
    } else {
      print('Building Login');
      return const Login();
    }
  }
}

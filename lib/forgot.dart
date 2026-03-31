
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  TextEditingController email= TextEditingController();
  TextEditingController password= TextEditingController();
  Future<void> reset()async {
    await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.text);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forget password"),
      ),
      body: Padding(
        padding:const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(
                hintText: "Enter email",
              ),
            ),
            ElevatedButton(onPressed: (()=>reset()), child:Text("Send link"), )
          ],
        ),
      ),
    );
  }
}

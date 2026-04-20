import 'package:app7/forgot.dart';
import 'package:app7/signup.dart';
import 'package:app7/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;

  // Validation states email passward
  String? emailError;
  String? passwordError;

  // Email validation function
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Real-time email validation
  void validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        emailError = null;
      } else if (!_isValidEmail(value)) {
        emailError = 'Please enter a valid email address';
      } else {
        emailError = null;
      }
    });
  }

  // Real-time password validation
  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        passwordError = null;
      } else if (value.length < 6) {
        passwordError = 'Password must be at least 6 characters';
      } else {
        passwordError = null;
      }
    });
  }

  //SignIn function
  Future<void> signIn() async {
    setState(() {
      emailError = null;
      passwordError = null;
    });
    if (emailController.text.trim().isEmpty) {
      setState(() => emailError = 'Please enter your email');
      return;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      setState(() => emailError = 'Please enter a valid email address');
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() => passwordError = 'Please enter your password');
      return;
    }

    if (passwordController.text.length < 6) {
      setState(() => passwordError = 'Password must be at least 6 characters');
      return;
    }

    setState(() => isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        bool isCR = false;

        if (userDoc.exists) {
          isCR = userDoc['isCR'] ?? false;
        } else {
          isCR = (user.email == 'test1@gmail.com');
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'email': user.email,
                'isCR': isCR,
                'createdAt': FieldValue.serverTimestamp(),
              });
        }

        Get.offAll(() => Wrapper());
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled';
      }

      Get.snackbar(
        'Login Failed! Try Again.',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcoming Text
                const Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.blue[600]),
                ),
                const SizedBox(height: 40),

                // If Email Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'studentruet@gmail.com',
                    prefixIcon: Icon(
                      Icons.email,
                      color: emailError != null ? Colors.red : Colors.blue,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: emailError != null
                            ? Colors.red
                            : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: emailError != null ? Colors.red : Colors.blue,
                        width: 2,
                      ),
                    ),
                    errorText: emailError,
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 20),
                // if Password Field
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  onChanged: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(
                      Icons.lock,
                      color: passwordError != null ? Colors.red : Colors.blue,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: passwordError != null
                            ? Colors.red
                            : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: passwordError != null ? Colors.red : Colors.blue,
                        width: 2,
                      ),
                    ),
                    errorText: passwordError,
                    errorStyle: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 12),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.to(() => const Forgot()),
                    child: const Text(
                      'Forget Password?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  onPressed: isLoading ? null : signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const SignUp()),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

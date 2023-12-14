// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resculpt/portals/signin.dart';
import 'package:resculpt/portals/verify_email.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cpasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cpasswordController.dispose();
    super.dispose();
  }

  Future<void> addUserDetails(String username, String email) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          "uname": username,
          "email": email,
          "uid": user.uid,
        });
      } else {
        // Handle the case where user is null (not signed in)
        //print("User is not signed in");
      }
    } catch (e) {
      //print("Error adding user details: $e");
      // Handle the error as needed
    }
  }

  void registerUser() async {
    final uname = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final cpassword = _cpasswordController.text.trim();

    if (uname.isNotEmpty &&
        email.isNotEmpty &&
        password == cpassword &&
        password.length >= 8) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        addUserDetails(
          uname,
          email,
        );
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VerifyEmail(),
          ),
        );
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _cpasswordController.clear();
      } on FirebaseAuthException catch (e) {
        showAlertDialog(context, "Invalid Input", e.code);
      } catch (e) {
        // print("something bad happened");
        // print(
        //     e.runtimeType); //this will give the type of exception that occured
        // print(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (uname.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter username");
    } else if (email.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter your email");
    } else if (!email.contains('@')) {
      showAlertDialog(context, "Invalid Input", "please enter correct email");
    } else if (!email.contains('@')) {
      showAlertDialog(context, "Invalid Input", "please enter correct email");
    } else if (password.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter password");
    } else if (password.length < 8) {
      showAlertDialog(context, "Invalid Input",
          "password length must be minimum of 8 characters");
    } else if (password != cpassword) {
      showAlertDialog(context, "Invalid Input",
          "password and confirm password are not same");
    }
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text(
                'OK',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signup page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "username",
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "email",
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "password",
              ),
            ),
            TextField(
              controller: _cpasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "confirm password",
              ),
            ),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _isLoading ? null : registerUser,
                    child: const Text("Signup"),
                  ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Signin(),
                  ),
                );
              },
              child: const Text("Already have an account?"),
            ),
          ],
        ),
      ),
    );
  }
}

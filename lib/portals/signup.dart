// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resculpt/portals/constants.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Username",
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 7, bottom: 14),
          child: TextFormField(
            controller: _usernameController,
            validator: (value) {
              if (value!.isEmpty) {
                return "Field cannot be empty";
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.person,
                  color: primaryColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: primaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'Enter your name',
            ),
          ),
        ),
        const Text(
          "Email",
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 7, bottom: 14),
          child: TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value!.isEmpty) {
                return "Field cannot be empty";
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.mail,
                  color: primaryColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: primaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: 'Enter your email',
            ),
          ),
        ),
        const Text(
          "Password",
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 7, bottom: 14),
          child: TextFormField(
            controller: _passwordController,
            validator: (value) {
              if (value!.isEmpty) {
                return "Field cannot be empty";
              }
              return null;
            },
            obscureText: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.lock,
                  color: primaryColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: primaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const Text(
          "Confirm Password",
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 7, bottom: 14),
          child: TextFormField(
            controller: _cpasswordController,
            validator: (value) {
              if (value!.isEmpty) {
                return "Field cannot be empty";
              }
              return null;
            },
            obscureText: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.lock,
                  color: primaryColor,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFFE0037)),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  onPressed: _isLoading ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 56),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
                  ),
                  icon: const Icon(
                    CupertinoIcons.arrow_right,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
        ),
      ],
    );
  }
}

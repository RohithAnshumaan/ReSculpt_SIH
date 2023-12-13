// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void signinCont() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        Navigator.of(context).pushReplacementNamed('/loc');
        _emailController.clear();
        _passwordController.clear();
      } on FirebaseAuthException catch (e) {
        // print(e.code);
        showAlertDialog(context, "Invalid Input", e.code);
      } catch (e) {
        // print("something bad happened");
        // print(e
        //     .runtimeType); //this will give the type of exception that occured
        // print(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (email.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter email");
    } else if (password.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter password");
    }
  }

  void signinArt() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        Navigator.of(context).pushReplacementNamed('/arthome');
        _emailController.clear();
        _passwordController.clear();
      } on FirebaseAuthException catch (e) {
        // print(e.code);
        showAlertDialog(context, "Invalid Input", e.code);
      } catch (e) {
        // print("something bad happened");
        // print(e
        //     .runtimeType); //this will give the type of exception that occured
        // print(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (email.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter email");
    } else if (password.isEmpty) {
      showAlertDialog(context, "Invalid Input", "please enter password");
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
                style: TextStyle(color: Colors.deepPurple),
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
        title: const Text("Signin page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/forgotpassword');
                  },
                  child: const Text("Forgot password"),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : signinCont,
              child: const Text("Signin to Contribute"),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : signinArt,
              child: const Text("Signin as Artisan"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/');
              },
              child: const Text("Don't have an account?"),
            ),
          ],
        ),
      ),
    );
  }
}

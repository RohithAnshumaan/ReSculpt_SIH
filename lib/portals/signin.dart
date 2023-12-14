// ignore_for_file: use_build_context_synchronously

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:resculpt/artisan/artisan_home.dart';
// import 'package:resculpt/artisan/artisan_home1.dart';
// import 'package:resculpt/contributor/contributor_home.dart';
// import 'package:resculpt/contributor/contributor_home1.dart';
// import 'package:resculpt/portals/forgot_pass.dart';
// import 'package:resculpt/portals/signup.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Signin extends StatefulWidget {
//   const Signin({super.key});

//   @override
//   State<Signin> createState() => _SigninState();
// }

// class _SigninState extends State<Signin> {

// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:resculpt/artisan/artisan_home.dart';
import 'package:resculpt/contributor/contributor_home.dart';
import 'package:resculpt/portals/constants.dart';
import 'package:resculpt/portals/forgot_pass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> storeUserType(String userType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', userType);
  }

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  void signinContributor() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        await storeUserType('contributor');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ContributorHome(),
          ),
        );
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

  void signinArtisan() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        await storeUserType('artisan');
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ArtisanHome(),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Email",
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
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
            padding: const EdgeInsets.only(top: 8),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPassword(),
                    ),
                  );
                  Navigator.of(context).pushNamed('/');
                },
                child: const Text(
                  "Forgot password",
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
          // ElevatedButton(
          //   onPressed: _isLoading ? null : signinContributor,
          //   child: const Text("Signin as Contributor"),
          // ),
          // ElevatedButton(
          //   onPressed: _isLoading ? null : signinArtisan,
          //   child: const Text("Signin to Artisan"),
          // ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : signinContributor,
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
                "SignIn as Contributor",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : signinArtisan,
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
                "SignIn to Artisan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

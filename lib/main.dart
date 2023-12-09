import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:resculpt/artisan/artisan_home.dart';
import 'package:resculpt/contributor/contributor_home.dart';
import 'package:resculpt/firebase_options.dart';
import 'package:resculpt/portals/forgot_pass.dart';
import 'package:resculpt/portals/login.dart';
import 'package:resculpt/portals/signup.dart';
import 'package:resculpt/portals/verify_email.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const Signup(),
        '/signin': (context) => const Signin(),
        '/verify': (context) => const VerifyEmail(),
        '/forgotpassword': (context) => const ForgotPassword(),
        '/conhome': (context) => const ContributorHome(),
        '/arthome': (context) => const ArtisanHome()
      },
    );
  }
}

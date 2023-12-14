import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:resculpt/artisan/artisan_home.dart';
import 'package:resculpt/contributor/contributor_home.dart';
import 'package:resculpt/firebase_options.dart';
import 'package:resculpt/onboading_screen/onboarding_screen.dart';
import 'package:resculpt/portals/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Loading indicator or splash screen while checking auth state.
                return const MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Loading(),
                );
              }
              if (snapshot.hasData) {
                return const MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: HomeScreen(),
                );
              } else {
                return const MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: OnboardingScreen(),
                );
              }
            },
          );
        }
        // Loading indicator or splash screen while initializing Firebase.
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Loading(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          SharedPreferences prefs = snapshot.data!;
          String? userType = prefs.getString('userType');

          if (userType == 'contributor') {
            return const ContributorHome();
          } else {
            return const ArtisanHome();
          }
        } else {
          return const Loading();
        }
      },
    );
  }
}

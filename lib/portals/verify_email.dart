import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool isVerified = false;
  Timer? timer;

  Future<void> sendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isVerified) {
      timer?.cancel();
      // Navigate to the '/account' route after email verification
      Navigator.of(context).pushNamed('/signin');
    }
  }

  @override
  void initState() {
    super.initState();
    isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isVerified) {
      sendVerificationEmail();

      if (timer == null || !timer!.isActive) {
        timer = Timer.periodic(const Duration(seconds: 3), (_) {
          checkEmailVerified();
        });
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify email"),
      ),
      body: Center(
        child: isVerified
            ? const Text("Email verified")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "An email has been sent to your mail.\nPlease click on it to verify.\nIf there is no mail in your Inbox then check your SPAM.",
                  ),
                  ElevatedButton(
                    onPressed: sendVerificationEmail,
                    child: const Text("Resend Link"),
                  ),
                ],
              ),
      ),
    );
  }
}

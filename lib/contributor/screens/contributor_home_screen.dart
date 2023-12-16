import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resculpt/chat/all_chats.dart';
import 'package:resculpt/contributor/screens/fill_details_screen.dart';
import 'package:resculpt/contributor/widgets/get_data.dart';
import 'package:resculpt/portals/my_account.dart';

class ContributorHome extends StatefulWidget {
  const ContributorHome({super.key});

  @override
  State<ContributorHome> createState() => _ContributorHomeState();
}

class _ContributorHomeState extends State<ContributorHome> {
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Your listed items'),
      ),
      body: Column(
        children: [
          const GetData(),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FillDetails(),
                    ),
                  );
                },
                child: const Text('Upload'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllChats(),
                    ),
                  );
                },
                child: const Text("chat"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyAccount(),
                    ),
                  );
                },
                child: const Text("account"),
              ),
            ],
          )
        ],
      ),
    );
  }
}

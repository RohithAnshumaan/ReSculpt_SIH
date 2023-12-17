import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resculpt/chat/all_chats.dart';
import 'package:resculpt/contributor/screens/fill_details_screen.dart';
import 'package:resculpt/contributor/widgets/get_data.dart';
import 'package:resculpt/portals/constants.dart';
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, ),
          child: Row(
            children: [
              const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              const SizedBox(
                width: 5,
              ),
              const Text(
                "Your Listed Items",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              CircleAvatar(
                backgroundColor: const Color(0xffE6E6E6),
                radius: 20,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyAccount(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person),
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const GetData(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: primaryColor,
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FillDetails(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: const Text(
                      'UPLOAD',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllChats(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: const Text(
                      "CHAT",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

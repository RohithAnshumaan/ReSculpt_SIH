import 'package:flutter/material.dart';
import 'package:resculpt/chat/all_chats.dart';
import 'package:resculpt/artisan/screens/prod_details_screen.dart';
import 'package:resculpt/artisan/widgets/display.dart';
import 'package:resculpt/main.dart';
import 'package:resculpt/portals/constants.dart';
import 'package:resculpt/portals/my_account.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtisanHome extends StatefulWidget {
  const ArtisanHome({super.key});

  @override
  State<ArtisanHome> createState() => _ArtisanHomeState();
}

class _ArtisanHomeState extends State<ArtisanHome> {
  final _searchController = TextEditingController();
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  List<String> docIds = [];

  Future<void> getDocIds(String searchQuery) async {
    docIds.clear(); // Clear the previous list

    if (searchQuery.isEmpty) {
      // Retrieve all documents
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('waste').get();
      for (var document in querySnapshot.docs) {
        docIds.add(document.reference.id);
      }
    } else {
      // Retrieve documents based on the search query
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('waste').get();
      for (var document in querySnapshot.docs) {
        String title = document['Title'] ?? '';
        if (title.toLowerCase().contains(searchQuery.toLowerCase())) {
          docIds.add(document.reference.id);
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Text(
                "R E S C U L P T",
                style: TextStyle(
                  fontSize: 34,
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
          Container(
            height: 70,
            color: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      // This will trigger the FutureBuilder to rebuild and call getDocIds
                    });
                  },
                  icon: const Icon(Icons.search),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                hintText: "Search",
                enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                fillColor: Colors.grey[100],
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getDocIds(_searchController.text),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return ListView.builder(
                    itemCount: docIds.length,
                    itemBuilder: (context, index) {
                      return Display(documentId: docIds[index]);
                    },
                  );
                }
              },
            ),
          ),
          Container(
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
                          builder: (context) => const ProdDetails(),
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

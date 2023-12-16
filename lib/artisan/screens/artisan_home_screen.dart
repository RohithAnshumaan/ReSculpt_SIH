import 'package:flutter/material.dart';
import 'package:resculpt/chat/all_chats.dart';
import 'package:resculpt/artisan/screens/prod_details_screen.dart';
import 'package:resculpt/artisan/widgets/display.dart';
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
      // Retrieve all documents with the current user's email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('waste')
          .where('Email',
              isEqualTo:
                  currentUserEmail) // Replace 'currentUserEmail' with the actual variable storing the user's email
          .get();
      for (var document in querySnapshot.docs) {
        docIds.add(document.reference.id);
      }
    } else {
      // Retrieve documents based on the search query and the current user's email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('waste')
          .where('Email',
              isEqualTo:
                  currentUserEmail) // Replace 'currentUserEmail' with the actual variable storing the user's email
          .get();
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Shop'),
      ),
      body: Column(
        children: [
          TextField(
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
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProdDetails(),
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
          ),
        ],
      ),
    );
  }
}

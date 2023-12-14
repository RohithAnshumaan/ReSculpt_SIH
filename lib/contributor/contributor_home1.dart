import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resculpt/artisan/prod_details.dart';
import 'package:resculpt/contributor/widgets/get_data.dart';
import 'package:resculpt/portals/my_account.dart';

class ContributorHome1 extends StatefulWidget {
  const ContributorHome1({super.key});

  @override
  State<ContributorHome1> createState() => _ContributorHome1State();
}

class _ContributorHome1State extends State<ContributorHome1> {
  final _searchController = TextEditingController();
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  // list to store required document ids
  List<String> docIds = [];

  // get required docIds
  Future<void> getDocIds(String searchQuery) async {
    docIds.clear(); // Clear the previous list

    if (searchQuery.isEmpty) {
      // Retrieve all documents with the current user's email
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('waste')
          .where('email',
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
          .where('email',
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
        title: const Text('contributor'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  // Remove the following line to avoid duplicate calls
                  // getDocIds(_searchController.text);

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
                      return GetData(documentId: docIds[index]);
                    },
                  );
                }
              },
            ),
          ),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProdDetails(),
                    ),
                  );
                },
                child: const Text('Upload')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
    );
  }
}

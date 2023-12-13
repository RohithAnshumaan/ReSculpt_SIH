import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resculpt/artisan/prod_details.dart';
import 'package:resculpt/contributor/widgets/get_data.dart';
import 'package:resculpt/portals/my_account.dart';

class ArtisanHome1 extends StatefulWidget {
  const ArtisanHome1({super.key});

  @override
  State<ArtisanHome1> createState() => _ArtisanHome1State();
}

class _ArtisanHome1State extends State<ArtisanHome1> {
  final _searchController = TextEditingController();

  // list to store required document ids
  List<String> docIds = [];

  // get required docIds
  Future<void> getDocIds(String searchQuery) async {
    docIds.clear(); // Clear the previous list

    if (searchQuery.isEmpty) {
      // Retrieve all documents
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('waste').get();
      querySnapshot.docs.forEach((document) {
        docIds.add(document.reference.id);
      });
    } else {
      // Retrieve documents based on the search query
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('waste').get();
      querySnapshot.docs.forEach((document) {
        String title = document['Title'] ?? '';
        if (title.toLowerCase().contains(searchQuery.toLowerCase())) {
          docIds.add(document.reference.id);
        }
      });
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
        title: const Text('artisan'),
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

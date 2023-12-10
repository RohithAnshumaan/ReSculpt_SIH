import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisplayCard extends StatefulWidget {
  const DisplayCard({super.key});

  @override
  State<DisplayCard> createState() => _DisplayCardState();
}

class _DisplayCardState extends State<DisplayCard> {
  String? userEmail = FirebaseAuth.instance.currentUser?.email;

  late Stream<QuerySnapshot<Map<String, dynamic>>> _itemsStream =
      const Stream.empty();

  @override
  void initState() {
    super.initState();
    _initializeEventsStream();
  }

  void _initializeEventsStream() {
    _itemsStream = FirebaseFirestore.instance
        .collection("waste")
        .where("Email", isEqualTo: userEmail)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _itemsStream,
      builder: ((context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No items found'),
          );
        }
        final itemsData = snapshot.data!.docs;
        return ListView.builder(
          itemCount: itemsData.length,
          itemBuilder: ((context, index) {
            final item = itemsData[index].data();
            // final email = item['Email'];
            final title = item['Title'];
            final desc = item['Description'];
            final cat = item['Category'];
            final ad = item['Address'];
            final price = item['Price'];

            return ListTile(
              subtitle: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Card(
                      elevation: 7,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          // Text(email),
                          Text(title),
                          Text(desc),
                          Text(cat),
                          Text(ad),
                          Text(price.toString()),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
        );
      }),
    ));
  }
}

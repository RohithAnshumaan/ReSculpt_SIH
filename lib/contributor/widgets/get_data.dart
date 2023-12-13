import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetData extends StatelessWidget {
  const GetData({
    super.key,
    required this.documentId,
  });

  final String documentId;

  @override
  Widget build(BuildContext context) {
    CollectionReference dbData =
        FirebaseFirestore.instance.collection('innovations');
    return FutureBuilder<DocumentSnapshot>(
      future: dbData.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            children: [
              Text(data['Title']),
              Text(data['Category']),
              Text(data['Description']),
              Text(data['Price'].toString()),
              const SizedBox(height: 30),
            ],
          );
        }
        return const Text("loading...");
      },
    );
  }
}

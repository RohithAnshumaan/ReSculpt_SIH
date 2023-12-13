import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class GetData extends StatelessWidget {
  GetData({
    super.key,
    required this.documentId,
  });

  final String documentId;
  final storage = FirebaseStorage.instance.ref();

  Future<String> getImageUrl(dynamic id) async {
    final waste = storage.child('waste');
    // final mail = waste.child('$userEmail');
    final imgRef = waste.child('$id.png');
    final networkImgUrl = await imgRef.getDownloadURL();
    return networkImgUrl;
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference dbData = FirebaseFirestore.instance.collection('waste');
    return FutureBuilder<DocumentSnapshot>(
      future: dbData.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          String imgId = data['ImgId'];
          return FutureBuilder(
              future: getImageUrl(imgId),
              builder: ((context, urlSnapshot) {
                if (urlSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (urlSnapshot.hasError) {
                  // print('Error loading image: ${urlSnapshot.error}');
                  return const Text('Error loading image');
                } else if (!urlSnapshot.hasData || urlSnapshot.data == null) {
                  return const Text('No image available');
                } else {
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image on the left
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Image.network(
                                        urlSnapshot
                                            .data!, // Use the retrieved URL here
                                        fit: BoxFit
                                            .cover, // Adjust as per your UI requirement
                                      ),
                                    ),
                                  ),
                                  // Text on the right
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(data['Title']),
                                          Text(data['Description']),
                                          Text(data['Category']),
                                          Text(data['City']),
                                          Text(data['State']),
                                          Text(data['Price'].toString()),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                      ],
                    ),
                  );
                }
              }));
        }
        return const Text("loading...");
      },
    );
  }
}

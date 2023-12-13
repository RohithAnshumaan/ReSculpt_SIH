import 'package:firebase_storage/firebase_storage.dart';
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
  final storage = FirebaseStorage.instance.ref();
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

  Future<String> getImageUrl(dynamic id) async {
    final waste = storage.child('waste');
    final mail = waste.child('$userEmail');
    final imgRef = mail.child('$id.png');
    final networkImgUrl = await imgRef.getDownloadURL();
    return networkImgUrl;
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
            final id = item['ImgId'];
            final title = item['Title'];
            final desc = item['Description'];
            final cat = item['Category'];
            final city = item['City'];
            final state = item['State'];
            final price = item['Price'];
            return FutureBuilder(
                future: getImageUrl(id),
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
                                            Text(title),
                                            Text(desc),
                                            Text(cat),
                                            Text(city),
                                            Text(state),
                                            Text(price.toString()),
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
          }),
        );
      }),
    ));
  }
}

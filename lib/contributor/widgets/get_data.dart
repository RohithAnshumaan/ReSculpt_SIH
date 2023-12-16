import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class GetData extends StatefulWidget {
  const GetData({super.key});

  @override
  State<GetData> createState() => _GetDataState();
}

class _GetDataState extends State<GetData> {
  final storage = FirebaseStorage.instance.ref();

  late Stream<QuerySnapshot<Map<String, dynamic>>> _itemsStream =
      const Stream.empty();

  final email = FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
    _initializeEventsStream();
  }

  Future<String> getImageUrl(dynamic id) async {
    final waste = storage.child('waste');
    // final mail = waste.child('$userEmail');
    final imgRef = waste.child('$id.png');
    final networkImgUrl = await imgRef.getDownloadURL();
    return networkImgUrl;
  }

  void _initializeEventsStream() async {
    _itemsStream = FirebaseFirestore.instance
        .collection("waste")
        .where('Email', isEqualTo: email)
        .snapshots();
    setState(() {
      _itemsStream = _itemsStream;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _itemsStream,
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text('Loading'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No contributions'),
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
                builder: (context, urlSnapshot) {
                  if (urlSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (urlSnapshot.hasError) {
                    // print('Error loading image: ${urlSnapshot.error}');
                    return const Text('Error loading image');
                  } else if (!urlSnapshot.hasData || urlSnapshot.data == null) {
                    return const Text('No image available');
                  } else {
                    return ListTile(
                        subtitle: Column(children: [
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
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
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
                    ]));
                  }
                },
              );
            }),
          );
        }),
      ),
    );
  }
}

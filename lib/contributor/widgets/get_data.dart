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
                          subtitle: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal:10.0, vertical: 10),
                                child: Card(
                                  surfaceTintColor: Colors.white,
                                  elevation: 15,
                                  shape: const RoundedRectangleBorder(),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Image on the left
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: 150,
                                              height: 170,
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    title,
                                                    style:const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    desc,
                                                    style:
                                                        const TextStyle(fontSize: 16),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    cat,
                                                    style:
                                                      const TextStyle(fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        city,
                                                        style:
                                                          const TextStyle(fontSize: 16),
                                                      ),
                                                      const Text(
                                                        ", ",
                                                        style:
                                                          TextStyle(fontSize: 16),
                                                      ), 
                                                      ],
                                                  ),                                                     
                                                      Text(
                                                        state,
                                                        style:
                                                          const TextStyle(fontSize: 16),
                                                      ),
                                                    
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      const Text(
                                                        "Price: ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16),
                                                      ),
                                                      Text(
                                                        price.toString(),
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),                                     
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
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

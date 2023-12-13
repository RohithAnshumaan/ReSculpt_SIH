import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class DisplayAll extends StatefulWidget {
  const DisplayAll({super.key});

  @override
  State<DisplayAll> createState() => _DisplayAllState();
}

class _DisplayAllState extends State<DisplayAll> {
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  // String _area = "";
  String _city = "";
  // String _locality = "";
  // String _state = "";
  // String _postalCode = "";
  final storage = FirebaseStorage.instance.ref();
  late Stream<QuerySnapshot<Map<String, dynamic>>> _itemsStream =
      const Stream.empty();

  @override
  void initState() {
    super.initState();
    _initializeEventsStream();
  }

  void _initializeEventsStream() async {
    String city = await _requestLocationPermission();
    _itemsStream = FirebaseFirestore.instance
        .collection("waste")
        .where('Address', arrayContains: city.toLowerCase())
        .snapshots();
  }

  Future<String> _requestLocationPermission() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    String city = await _getCurrentLocation();
    return city;
  }

  Future<String> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          // _area = placemark.subAdministrativeArea ?? "";
          _city = placemark.locality ?? "";
          // _locality = placemark.subLocality ?? "";
          // _state = placemark.administrativeArea ?? "";
          // _postalCode = placemark.postalCode ?? "";
        });
      } else {
        setState(() {
          // _area = "Not available";
          _city = "Not available";
          // _locality = "Not available";
          // _state = "Not available";
          // _postalCode = "Not available";
        });
      }
    } catch (e) {
      //print("Error: $e");
      setState(() {
        // _area = "Error getting location";
        _city = "Error getting location";
        // _locality = "Error getting location";
        // _state = "Error getting location";
        // _postalCode = "Error getting location";
      });
    }
    return _city;
  }

  // Future<String> getImageUrl(dynamic id) async {
  //   final waste = storage.child('waste');
  //   final imgRef = waste.child('$id.png');
  //   final networkImgUrl = await imgRef.getDownloadURL();
  //   return networkImgUrl;
  // }

  Future<String> getImageUrl(dynamic id) async {
    Reference wastesRef = storage.child('waste');
    try {
      ListResult result = await wastesRef.listAll();

      for (Reference userRef in result.prefixes) {
        ListResult userItems = await userRef.listAll();

        for (Reference imageRef in userItems.items) {
          String imageName = imageRef.name
              .split('.')
              .first; // Get image name without extension

          if (imageName == id) {
            String downloadURL = await imageRef.getDownloadURL();
            return downloadURL;
          }
        }
      }
      return '';
    } catch (e) {
      // print('Error retrieving images: $e');
      return '';
    }
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
            // print('id:$id');
            final title = item['Title'];
            final desc = item['Description'];
            final cat = item['Category'];
            final ad = item['Address'];
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
                                            Text(ad.toString()),
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:resculpt/artisan/screens/chat_page_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:resculpt/artisan/screens/chat_page_screen.dart';

class Display extends StatefulWidget {
  const Display({super.key, required this.documentId});
  final String documentId;
  @override
  State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  // late Stream<QuerySnapshot<Map<String, dynamic>>> _itemsStream =
  //     const Stream.empty();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;
  late String _city_ = "";
  final storage = FirebaseStorage.instance.ref();
  CollectionReference dbData = FirebaseFirestore.instance.collection('waste');

  //updating with whom the current user has chatted
  Future<void> addChattedWith(String receiverEmail) async {
    try {
      String? currEmail = _auth.currentUser!.email;
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: currEmail)
          .get();
      if (userQuery.docs.isNotEmpty) {
        DocumentReference userRef = userQuery.docs.first.reference;
        await userRef.update({
          'chattedWith': FieldValue.arrayUnion([receiverEmail]),
        });
        // print('ChattedWith updated successfully.');
      } else {
        // print('User not found.');
        // Handle the case where the user document is not found
      }
    } catch (error) {
      // print('Error updating chattedWith: $error');
      // Handle the error as needed
    }
  }

  //updating the chattedWith array in receivers document
  Future<void> addChattedWithInReceiver(String receiverEmail) async {
    try {
      String? currEmail = _auth.currentUser!.email;
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: receiverEmail)
          .get();
      if (userQuery.docs.isNotEmpty) {
        DocumentReference userRef = userQuery.docs.first.reference;
        await userRef.update({
          'chattedWith': FieldValue.arrayUnion([currEmail]),
        });
        // print('ChattedWith updated successfully.');
      } else {
        // print('User not found.');
        // Handle the case where the user document is not found
      }
    } catch (error) {
      // print('Error updating chattedWith: $error');
      // Handle the error as needed
    }
  }

  Future<String?> getReceiverId(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['uid'];
      } else {
        return null;
      }
    } catch (e) {
      // print('Error getting receiver ID: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCity();
    // _initializeEventsStream();
  }

  // void _initializeEventsStream() async {
  //   String city = await _requestLocationPermission();
  //   _itemsStream = FirebaseFirestore.instance
  //       .collection("waste")
  //       .where("City", isEqualTo: city)
  //       .snapshots();
  // }

  Future<void> _requestLocationPermission() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _initializeCity() async {
    await _requestLocationPermission(); // Request location permission
    await _getCurrentLocation(); // Get current location
  }

  Future<void> _getCurrentLocation() async {
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
          _city_ = placemark.locality ?? "";
        });
      } else {
        //error
      }
    } catch (e) {
      //print("Error: $e");
    }
  }

  Future<String> getImageUrl(dynamic id) async {
    try {
      Reference imageRef = storage.child('waste/$id.png');
      String downloadURL = await imageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: dbData.doc(widget.documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // print("error : ${snapshot.error}");
          return const Text("error");
        } else {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          String imgId = data['ImgId'];
          String place = data['City'];
          if (place == _city_) {
            return Column(
              children: [
                FutureBuilder(
                    future: getImageUrl(imgId),
                    builder: ((context, urlSnapshot) {
                      if (urlSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (urlSnapshot.hasError) {
                        // print('Error loading image: ${urlSnapshot.error}');
                        return const Text('Error loading image');
                      } else if (!urlSnapshot.hasData ||
                          urlSnapshot.data == null) {
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                Center(
                                                  child: Column(
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          // Use 'await' to get the result of the asynchronous function
                                                          String? id =
                                                              await getReceiverId(
                                                                  data[
                                                                      'Email']);
                                                          // print(email);
                                                          // print(id);
                                                          addChattedWith(
                                                              data['Email']);
                                                          addChattedWithInReceiver(
                                                              data['Email']);
                                                          // Check if 'id' is not null before using it
                                                          if (id != null) {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ChatPage(
                                                                  receiverEmail:
                                                                      data[
                                                                          'Email'],
                                                                  receiverUserId:
                                                                      id,
                                                                ),
                                                              ),
                                                            );
                                                          } else {
                                                            // Handle the case where no matching document is found
                                                            // print('No matching document found for email: $email');
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Chat with owner'),
                                                      ),
                                                    ],
                                                  ),
                                                )
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
                    })),
              ],
            );
          } else {
            return Container();
          }
        }
      },
    );
  }
}

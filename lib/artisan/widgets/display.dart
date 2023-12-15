import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resculpt/artisan/screens/chat_page_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Display extends StatefulWidget {
  const Display({super.key});

  @override
  State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _itemsStream =
      const Stream.empty();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;
  String _city = "";
  final storage = FirebaseStorage.instance.ref();

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
    _initializeEventsStream();
  }

  void _initializeEventsStream() async {
    String city = await _requestLocationPermission();
    _itemsStream = FirebaseFirestore.instance
        .collection("waste")
        .where("City", isEqualTo: city)
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
  void dispose() {
    super.dispose();
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
              child: Text('No items found'),
            );
          }
          final itemsData = snapshot.data!.docs;
          return ListView.builder(
            itemCount: itemsData.length,
            itemBuilder: ((context, index) {
              final item = itemsData[index].data();
              final id = item['ImgId'];
              final email = item['Email'];
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
                                        Text(email),
                                        Text(title),
                                        Text(desc),
                                        Text(cat),
                                        Text(city),
                                        Text(state),
                                        Text(price.toString()),
                                        Center(
                                          child: Column(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                  // Use 'await' to get the result of the asynchronous function
                                                  String? id =
                                                      await getReceiverId(
                                                          email);
                                                  // print(email);
                                                  // print(id);
                                                  addChattedWith(email);
                                                  addChattedWithInReceiver(
                                                      email);
                                                  // Check if 'id' is not null before using it
                                                  if (id != null) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChatPage(
                                                          receiverEmail: email,
                                                          receiverUserId: id,
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

//   void _navigateToChatRoom(
//       BuildContext context, String ownerId, String productName) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatRoom(
//           ownerId: ownerId,
//           productName: productName,
//         ),
//       ),
//     );
//   }
// }

// class ChatRoom extends StatefulWidget {
//   final String ownerId;
//   final String productName;

//   const ChatRoom({super.key, required this.ownerId, required this.productName});

//   @override
//   State<ChatRoom> createState() => _ChatRoomState();
// }

// class _ChatRoomState extends State<ChatRoom> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   late User _currentUser;
//   late TextEditingController _messageController;
//   late CollectionReference _chatCollection;

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentUser();
//     _messageController = TextEditingController();
//     _chatCollection = _firestore.collection('chats');
//   }

//   void _getCurrentUser() async {
//     _currentUser = FirebaseAuth.instance.currentUser!;
//   }

//   void _sendMessage(String message) {
//     _chatCollection.add({
//       'productId': widget.productName,
//       'senderId': _currentUser.email, // Use email as the unique identifier
//       'receiverId': widget.ownerId,
//       'message': message,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//     _messageController.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with ${widget.productName} Owner'),
//       ),
//       body: Column(
//         children: [
//           // Display chat messages here
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _chatCollection
//                   .where('productId', isEqualTo: widget.productName)
//                   .orderBy('timestamp', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return const Center(
//                     child: Text('No messages yet'),
//                   );
//                 }

//                 final messages = snapshot.data!.docs;
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final message =
//                         messages[index].data()! as Map<String, dynamic>;
//                     final isMe = message['senderId'] == _currentUser.email;
//                     return Align(
//                       alignment:
//                           isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(
//                             vertical: 10, horizontal: 10),
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 10, horizontal: 15),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           color: isMe ? Colors.blue[200] : Colors.grey.shade200,
//                         ),
//                         child: Text(
//                           message['message'].toString(),
//                           style: const TextStyle(fontSize: 15),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),

//           // Input field for typing messages
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Type your message...',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     if (_messageController.text.isNotEmpty) {
//                       _sendMessage(_messageController.text);
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
}
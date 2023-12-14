import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resculpt/artisan/chat_page.dart';

class Display extends StatefulWidget {
  const Display({super.key});

  @override
  State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _itemsStream =
      const Stream.empty();

  @override
  void initState() {
    super.initState();
    _initializeEventsStream();
  }

  void _initializeEventsStream() {
    _itemsStream = FirebaseFirestore.instance.collection("waste").snapshots();
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
              final email = item['Email'];
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
                            Text(email),
                            Text(title),
                            Text(desc),
                            Text(cat),
                            Text(ad.toString()),
                            Text(price.toString()),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                        receiverEmail: email,
                                        receiverUserId: FirebaseAuth
                                            .instance.currentUser!.uid),
                                  ),
                                );
                              },
                              child: const Text('Chat'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Implement the buy functionality
                              },
                              child: const Text('Buy'),
                            ),
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

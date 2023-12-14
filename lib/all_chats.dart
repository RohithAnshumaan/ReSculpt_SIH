import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resculpt/artisan/chat_page.dart';

class AllChats extends StatefulWidget {
  const AllChats({super.key});

  @override
  State<AllChats> createState() => _AllChatsState();
}

class _AllChatsState extends State<AllChats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("all chats"),
      ),
      body: _buildUsersList(),
    );
  }

  // //build a list of users except for the current user
  // Widget _buildUsersList() {
  //   return StreamBuilder(
  //     stream: FirebaseFirestore.instance.collection('users').snapshots(),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasError) {
  //         return Text(snapshot.error.toString());
  //       }
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Text("Loading");
  //       }
  //       return ListView(
  //         children: snapshot.data!.docs
  //             .map((document) => _buildUsersListItem(document))
  //             .toList(),
  //       );
  //     },
  //   );
  // }

  // Widget _buildUsersListItem(DocumentSnapshot document) {
  //   Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

  //   //display all users except current user
  //   if (FirebaseAuth.instance.currentUser!.email != data['email']) {
  //     return ListTile(
  //       title: Text(data['email']),
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ChatPage(
  //               receiverEmail: data['email'],
  //               receiverUserId: data['uid'],
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }
  //   return Container();
  // }

  Widget _buildUsersList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        final FirebaseAuth _auth = FirebaseAuth.instance;

        // Filter the users based on the chattedWith array
        List<DocumentSnapshot> chattedWithUsers = snapshot.data!.docs
            .where((document) =>
                _isUserInChattedWithArray(document, _auth.currentUser?.email))
            .toList();

        return ListView(
          children: chattedWithUsers
              .map((document) => _buildUsersListItem(document))
              .toList(),
        );
      },
    );
  }

  bool _isUserInChattedWithArray(
      DocumentSnapshot document, String? currentUserEmail) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // Check if the current user's email is in the 'chattedWith' array
    List<dynamic>? chattedWith = data['chattedWith'];
    return chattedWith != null &&
        currentUserEmail != null &&
        chattedWith.contains(currentUserEmail);
  }

  Widget _buildUsersListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    return ListTile(
      title: Text(data['uname']),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: data['email'],
              receiverUserId: data['uid'],
            ),
          ),
        );
      },
    );
  }
}

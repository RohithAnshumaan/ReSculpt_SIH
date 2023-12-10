import 'package:cloud_firestore/cloud_firestore.dart';

class WasteObject {
  WasteObject(
      {this.id,
      required this.type,
      required this.email,
      required this.title,
      required this.desc,
      required this.cat,
      required this.adr,
      required this.price});

  final String? email;
  final String type;
  final String? id;
  final String title;
  final String desc;
  final String cat;
  final String adr;
  final double price;

  toJson() {
    return {
      'Type': type,
      'Email': email,
      'Title': title,
      'Description': desc,
      'Category': cat,
      'Address': adr,
      'Price': price
    };
  }

  factory WasteObject.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return WasteObject(
        id: doc.id,
        type: data['Type'],
        email: data['Email'],
        title: data['Title'],
        desc: data['Description'],
        cat: data['Category'],
        adr: data['Address'],
        price: data['Price']);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class WasteObject {
  WasteObject(
      {this.id,
      this.imgId,
      required this.email,
      required this.title,
      required this.desc,
      required this.cat,
      required this.state,
      required this.city,
      required this.price});

  final dynamic imgId;
  final String? email;
  final String? id;
  final String title;
  final String desc;
  final String cat;
  final String city;
  final String state;
  final double price;

  toJson() {
    return {
      'ImgId': imgId,
      'Email': email,
      'Title': title,
      'Description': desc,
      'Category': cat,
      'City': city,
      'State': state,
      'Price': price
    };
  }

  factory WasteObject.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return WasteObject(
        id: doc.id,
        email: data['Email'],
        title: data['Title'],
        desc: data['Description'],
        cat: data['Category'],
        city: data['City'],
        state: data['State'],
        price: data['Price']);
  }
}

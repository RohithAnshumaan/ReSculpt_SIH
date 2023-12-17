import 'package:cloud_firestore/cloud_firestore.dart';

class ProductObject {
  ProductObject(
      {this.id,
      this.imgId,
      this.timestamp,
      required this.email,
      required this.title,
      required this.desc,
      required this.quan,
      required this.state,
      required this.city,
      required this.price});

  final dynamic imgId;
  final String? email;
  final String? id;
  final String title;
  final String desc;
  final String quan;
  final String city;
  final String state;
  final double price;
  final DateTime? timestamp;

  toJson() {
    return {
      'ImgId': imgId,
      'Email': email,
      'Title': title,
      'Description': desc,
      'Quantity': quan,
      'City': city,
      'State': state,
      'Price': price,
      'Timestamp': timestamp,
    };
  }

  factory ProductObject.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProductObject(
        id: doc.id,
        email: data['Email'],
        title: data['Title'],
        desc: data['Description'],
        quan: data['Quantity'],
        city: data['City'],
        state: data['State'],
        price: data['Price']);
  }
}

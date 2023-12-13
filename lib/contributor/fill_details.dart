import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resculpt/models/waste_object.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:resculpt/randomkey.dart';

class FillDetails extends StatefulWidget {
  const FillDetails({super.key});

  @override
  State<FillDetails> createState() => _FillDetailsState();
}

class _FillDetailsState extends State<FillDetails> {
  late File _selectedImage;
  final _db = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();
  final email = FirebaseAuth.instance.currentUser?.email;

  List<DropdownMenuEntry<dynamic>> dropdownMenuEntries = [
    const DropdownMenuEntry(value: 1, label: "plastic"),
    const DropdownMenuEntry(value: 2, label: "glass"),
    const DropdownMenuEntry(value: 3, label: "fabric"),
    const DropdownMenuEntry(value: 4, label: "metal"),
    const DropdownMenuEntry(value: 1, label: "wood")
  ];

  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _cat;
  late final TextEditingController _adr;
  late final TextEditingController _price;

  @override
  void initState() {
    _title = TextEditingController();
    _desc = TextEditingController();
    _cat = TextEditingController();
    _adr = TextEditingController();
    _price = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _cat.dispose();
    _adr.dispose();
    _price.dispose();
    super.dispose();
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.deepPurple),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future submitDetails() async {
    final title = _title.text.trim();
    final description = _desc.text.trim();
    final category = _cat.text.trim();
    final faddress = _adr.text.trim();
    final address = faddress.split(',');
    final double price = double.parse(_price.text.trim());
    final dynamic imgId = await _pickImageFromGallery();

    if (imgId == null) {
      return AlertDialog(
        title: const Text('ERROR'),
        content: const Text('Image not found.'),
        actions: [
          TextButton(
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.deepPurple),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    }
    WasteObject obj = WasteObject(
        imgId: imgId,
        email: email,
        title: title,
        desc: description,
        cat: category,
        adr: address,
        price: price);
    await _db.collection('waste').add(obj.toJson());
  }

  Future _storeImageToDb(File selectedImage) async {
    final randId = randomIdGenerator();
    final wasteRef = storageRef.child("waste");
    final itemRef = wasteRef.child("$email");
    final imageRef = itemRef.child("$randId.png");
    await imageRef.putFile(_selectedImage);
    return randId;
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) return;
    _selectedImage = File(returnedImage.path);
    final imgId = await _storeImageToDb(_selectedImage);
    return imgId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Enter item details'),
      ),
      body: Column(
        children: [
          TextField(
              controller: _title,
              decoration: const InputDecoration(hintText: "Enter title")),
          TextField(
            controller: _desc,
            decoration: const InputDecoration(hintText: "Enter description"),
          ),
          DropdownMenu<dynamic>(
              controller: _cat,
              hintText: "type",
              initialSelection: dropdownMenuEntries.first,
              dropdownMenuEntries: dropdownMenuEntries),
          TextField(
            controller: _adr,
            decoration: const InputDecoration(hintText: "Enter location"),
          ),
          TextField(
            controller: _price,
            decoration: const InputDecoration(hintText: "Enter price"),
          ),
          ElevatedButton(
            onPressed: () {
              submitDetails();
              Navigator.pop(context);
            },
            child: const Text('Submit details'),
          ),
        ],
      ),
    );
  }
}

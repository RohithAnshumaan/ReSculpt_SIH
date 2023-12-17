import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resculpt/contributor/models/waste_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:resculpt/UniqueID/randomkey.dart';

class FillDetails extends StatefulWidget {
  const FillDetails({super.key});

  @override
  State<FillDetails> createState() => _FillDetailsState();
}

class _FillDetailsState extends State<FillDetails> {
  bool isImageUploaded = false;
  dynamic id = '';
  late File _selectedImage;
  final _db = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();
  final email = FirebaseAuth.instance.currentUser?.email;
  final storage = FirebaseStorage.instance.ref();

  List<DropdownMenuEntry<dynamic>> itemDropdownMenuEntries = [
    const DropdownMenuEntry(value: 1, label: "plastic"),
    const DropdownMenuEntry(value: 2, label: "glass"),
    const DropdownMenuEntry(value: 3, label: "fabric"),
    const DropdownMenuEntry(value: 4, label: "metal"),
    const DropdownMenuEntry(value: 1, label: "wood")
  ];

  List<DropdownMenuEntry<dynamic>> cityEntries = [
    const DropdownMenuEntry(value: 1, label: "Bangalore"),
    const DropdownMenuEntry(value: 2, label: "Chennai"),
    const DropdownMenuEntry(value: 3, label: "Delhi"),
    const DropdownMenuEntry(value: 4, label: "Hyderabad"),
    const DropdownMenuEntry(value: 1, label: "Kolkata")
  ];

  List<DropdownMenuEntry<dynamic>> stateEntries = [
    const DropdownMenuEntry(value: 1, label: "Telangana"),
    const DropdownMenuEntry(value: 2, label: "Tamil Nadu"),
    const DropdownMenuEntry(value: 3, label: "Delhi (UT)"),
    const DropdownMenuEntry(value: 4, label: "Karnataka"),
    const DropdownMenuEntry(value: 1, label: "West Bengal"),
  ];

  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _cat;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _price;

  @override
  void initState() {
    _title = TextEditingController();
    _desc = TextEditingController();
    _cat = TextEditingController();
    _city = TextEditingController();
    _state = TextEditingController();
    _price = TextEditingController();

    _title.addListener(updateButtonState);
    _desc.addListener(updateButtonState);
    _cat.addListener(updateButtonState);
    _city.addListener(updateButtonState);
    _state.addListener(updateButtonState);
    _price.addListener(updateButtonState);

    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _cat.dispose();
    _city.dispose();
    _state.dispose();
    _price.dispose();
    super.dispose();
  }

  void updateButtonState() {
    setState(() {}); // Trigger rebuild to update button state
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

  Future<String> getImageUrl(dynamic id) async {
    final waste = storage.child('waste');
    // final mail = waste.child('$userEmail');
    final imgRef = waste.child('$id.png');
    final networkImgUrl = await imgRef.getDownloadURL();
    return networkImgUrl;
  }

  bool areFieldsFilled() {
    return _title.text.isNotEmpty &&
        _desc.text.isNotEmpty &&
        _cat.text.isNotEmpty &&
        _price.text.isNotEmpty &&
        _city.text.isNotEmpty &&
        _state.text.isNotEmpty;
  }

  Future submitDetails() async {
    final title = _title.text.trim();
    final description = _desc.text.trim();
    final category = _cat.text.trim();
    final state = _state.text.trim();
    final city = _city.text.trim();
    final double price = double.parse(_price.text.trim());

    if (id != null) {
      WasteObject obj = WasteObject(
          imgId: id,
          email: email,
          title: title,
          desc: description,
          cat: category,
          city: city,
          state: state,
          price: price);
      await _db.collection('waste').add(obj.toJson());
    }
  }

  Future _storeImageToDb(File selectedImage) async {
    final randId = randomIdGenerator();
    final wasteRef = storageRef.child("waste");
    // final itemRef = wasteRef.child("$email");
    final imageRef = wasteRef.child("$randId.png");
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
              initialSelection: itemDropdownMenuEntries.first,
              dropdownMenuEntries: itemDropdownMenuEntries),
          TextField(
            controller: _price,
            decoration: const InputDecoration(hintText: "Enter price"),
          ),
          DropdownMenu<dynamic>(
              controller: _city,
              hintText: "city",
              initialSelection: cityEntries.first,
              dropdownMenuEntries: cityEntries),
          DropdownMenu<dynamic>(
              controller: _state,
              hintText: "state",
              initialSelection: stateEntries.first,
              dropdownMenuEntries: stateEntries),
          ElevatedButton(
            onPressed: areFieldsFilled()
                ? () async {
                    dynamic imgId = await _pickImageFromGallery();
                    setState(() {
                      id = imgId;
                      isImageUploaded = true;
                    });
                  }
                : null,
            child: const Text('Upload image'),
          ),
          if (isImageUploaded)
            Column(
              children: [
                FutureBuilder(
                  future: getImageUrl(id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // print('error : ${snapshot.error}');
                      showAlertDialog(
                          context, 'Error', "Error uploading image");
                      return const Text('Try again');
                    } else {
                      return ListTile(
                        subtitle: Column(
                          children: [
                            Card(
                              elevation: 7,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Image.network(
                                        snapshot.data.toString(),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text('Image uploaded successfully')
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }
                  },
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
        ],
      ),
    );
  }
}

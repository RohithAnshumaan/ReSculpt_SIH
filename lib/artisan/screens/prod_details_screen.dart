import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:resculpt/artisan/models/prod_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:resculpt/UniqueID/randomkey.dart';
import 'package:resculpt/portals/constants.dart';

class ProdDetails extends StatefulWidget {
  const ProdDetails({super.key});

  @override
  State<ProdDetails> createState() => _ProdDetailsState();
}

class _ProdDetailsState extends State<ProdDetails> {
  bool isImageUploaded = false;
  dynamic id = '';
  late File _selectedImage;
  final _db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance.ref();
  final email = FirebaseAuth.instance.currentUser?.email;

  List<DropdownMenuEntry<dynamic>> dropdownMenuEntries = [
    const DropdownMenuEntry(value: 1, label: "1"),
    const DropdownMenuEntry(value: 2, label: "2"),
    const DropdownMenuEntry(value: 3, label: "3"),
    const DropdownMenuEntry(value: 4, label: "4"),
    const DropdownMenuEntry(value: 5, label: "5")
  ];

  List<DropdownMenuEntry<dynamic>> cityEntries = [
    const DropdownMenuEntry(value: 1, label: "Bangalore"),
    const DropdownMenuEntry(value: 2, label: "Chennai"),
    const DropdownMenuEntry(value: 3, label: "Delhi"),
    const DropdownMenuEntry(value: 4, label: "Hyderabad"),
    const DropdownMenuEntry(value: 5, label: "Kolkata")
  ];

  List<DropdownMenuEntry<dynamic>> stateEntries = [
    const DropdownMenuEntry(value: 1, label: "Telangana"),
    const DropdownMenuEntry(value: 2, label: "Tamil Nade"),
    const DropdownMenuEntry(value: 3, label: "Delhi (UT)"),
    const DropdownMenuEntry(value: 4, label: "Karnataka"),
    const DropdownMenuEntry(value: 5, label: "West Bengal"),
  ];

  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _quan;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _price;

  @override
  void initState() {
    _title = TextEditingController();
    _desc = TextEditingController();
    _quan = TextEditingController();
    _city = TextEditingController();
    _state = TextEditingController();
    _price = TextEditingController();

    _title.addListener(updateButtonState);
    _desc.addListener(updateButtonState);
    _quan.addListener(updateButtonState);
    _city.addListener(updateButtonState);
    _state.addListener(updateButtonState);
    _price.addListener(updateButtonState);

    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _quan.dispose();
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
    final waste = storage.child('products');
    // final mail = waste.child('$userEmail');
    final imgRef = waste.child('$id.png');
    final networkImgUrl = await imgRef.getDownloadURL();
    return networkImgUrl;
  }

  Future submitDetails() async {
    final title = _title.text.trim();
    final description = _desc.text.trim();
    final quan = _quan.text.trim();
    final state = _state.text.trim();
    final city = _city.text.trim();
    final double price = double.parse(_price.text.trim());
    if (id != null) {
      ProductObject obj = ProductObject(
        imgId: id,
        email: email,
        title: title,
        desc: description,
        quan: quan,
        city: city,
        state: state,
        price: price,
        timestamp: DateTime.now(),
      );
      await _db.collection('innovations').add(obj.toJson());
    }
  }

  bool areFieldsFilled() {
    return _title.text.isNotEmpty &&
        _desc.text.isNotEmpty &&
        _quan.text.isNotEmpty &&
        _price.text.isNotEmpty &&
        _city.text.isNotEmpty &&
        _state.text.isNotEmpty;
  }

  Future _storeImageToDb(File selectedImage) async {
    final randId = randomIdGenerator();
    final prodRef = storage.child("products");
    // final itemRef = wasteRef.child("$email");
    final imageRef = prodRef.child("$randId.png");
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "UPLOAD",
            style: TextStyle(
              fontSize: 34,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.asset(
                'assets/uploadpage.json',
                fit: BoxFit.cover,
                height: 190,
              ),
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  hintText: "Enter Title",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0, // Adjust the width as needed
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 2.0, // Adjust the width as needed
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              TextField(
                controller: _desc,
                decoration: InputDecoration(
                  hintText: "Enter Description",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0, // Adjust the width as needed
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 2.0, // Adjust the width as needed
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.0, // Adjust the width as needed
        ),
        borderRadius: BorderRadius.circular(8),),
                child: DropdownMenu<dynamic>(
                    controller: _quan,
                    hintText: "quantity",
                    initialSelection: dropdownMenuEntries.first,
                    dropdownMenuEntries: dropdownMenuEntries),
              ),
              const SizedBox(
                height: 5,
              ),
              TextField(
                controller: _price,
                decoration: InputDecoration(
                  hintText: "Enter price",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2.0, // Adjust the width as needed
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primaryColor,
                      width: 2.0, // Adjust the width as needed
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.0, // Adjust the width as needed
        ),
        borderRadius: BorderRadius.circular(8),),
                child: DropdownMenu<dynamic>(
                    controller: _city,
                    hintText: "city",
                    initialSelection: cityEntries.first,
                    dropdownMenuEntries: cityEntries),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.0, // Adjust the width as needed
        ),
        borderRadius: BorderRadius.circular(8),),
                child: DropdownMenu<dynamic>(
                    controller: _state,
                    hintText: "state",
                    initialSelection: stateEntries.first,
                    dropdownMenuEntries: stateEntries),
              ),
              const SizedBox(
                height: 5,
              ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                  ),
                ),
                child: const Text(
                  'Upload image',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (isImageUploaded)
                Column(
                  children: [
                    FutureBuilder(
                      future: getImageUrl(id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          // print('error : ${snapshot.error}');
                          // showAlertDialog(
                          //     context, 'Error', "Error uploading image");
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: Image.network(
                                            snapshot.data.toString(),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                                'Image uploaded successfully', style: TextStyle(fontSize: 20),),
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
                    const SizedBox(
                      height: 5,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        submitDetails();
                        showAlertDialog(
                            context, "Success!", "Product listed successfully");
                        // Navigator.of(context).pop();
                      },
                      child: const Text('Submit details'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resculpt/contributor/models/waste_object.dart';
// import 'package:resculpt/contributor/widgets/display_card.dart';

class FillDetails extends StatefulWidget {
  const FillDetails({super.key});

  @override
  State<FillDetails> createState() => _FillDetailsState();
}

class _FillDetailsState extends State<FillDetails> {
  final _db = FirebaseFirestore.instance;

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

  Future submitDetails() async {
    final title = _title.text.trim();
    final description = _desc.text.trim();
    final category = _cat.text.trim();
    final address = _adr.text.trim();
    final double price = double.parse(_price.text.trim());
    WasteObject obj = WasteObject(
        title: title,
        desc: description,
        cat: category,
        adr: address,
        price: price);
    await _db.collection('items').add(obj.toJson());
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
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => DisplayCard(),
              //   ),
              // );
              Navigator.pop(context);
            },
            child: const Text('Submit details'),
          ),
        ],
      ),
    );
  }
}

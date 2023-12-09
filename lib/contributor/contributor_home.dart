import 'package:flutter/material.dart';
import 'package:resculpt/contributor/fill_details.dart';
import 'package:resculpt/contributor/widgets/display_card.dart';
// import 'package:prototype/image_upload.dart';

class ContributorHome extends StatefulWidget {
  const ContributorHome({super.key});

  @override
  State<ContributorHome> createState() => _ContributorHomeState();
}

class _ContributorHomeState extends State<ContributorHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Your listed items'),
      ),
      body: Column(children: [
        const DisplayCard(),
        Center(
          child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FillDetails()));
              },
              child: const Text('Upload')),
        ),
      ]),
    );
  }
}

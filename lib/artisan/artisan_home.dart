import 'package:flutter/material.dart';
import 'package:resculpt/artisan/prod_details.dart';
import 'package:resculpt/artisan/widgets/display_all.dart';

class ArtisanHome extends StatefulWidget {
  const ArtisanHome({super.key});

  @override
  State<ArtisanHome> createState() => _ArtisanHomeState();
}

class _ArtisanHomeState extends State<ArtisanHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Shop'),
      ),
      body: Column(children: [
        const DisplayAll(),
        Center(
          child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProdDetails()));
              },
              child: const Text('Upload')),
        ),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
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
      body: const Column(children: [
        DisplayAll(),
        // Center(
        //   child: ElevatedButton(
        //       onPressed: () {
        //         Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => const FillDetails()));
        //       },
        //       child: const Text('Upload')),
        // ),
      ]),
    );
  }
}

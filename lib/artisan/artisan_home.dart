import 'package:flutter/material.dart';
import 'package:resculpt/artisan/widgets/chat_art.dart';
import 'package:resculpt/artisan/prod_details.dart';
// import 'package:resculpt/artisan/widgets/display_all.dart';
import 'package:resculpt/portals/my_account.dart';

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
      body: Column(
        children: [
          const Display(),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProdDetails(),
                    ),
                  );
                },
                child: const Text('Upload')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyAccount(),
            ),
          );
        },
        child: const Text("account"),
      ),
    );
  }
}

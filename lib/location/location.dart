import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  final db = FirebaseFirestore.instance;
  final email = FirebaseAuth.instance.currentUser?.email;
  String _area = "";
  String _city = "";
  String _locality = "";
  String _state = "";
  String _postalCode = "";

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Geolocator.checkPermission();
    if (status == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          _area = placemark.subAdministrativeArea ?? "";
          _city = placemark.locality ?? "";
          _locality = placemark.subLocality ?? "";
          _state = placemark.administrativeArea ?? "";
          _postalCode = placemark.postalCode ?? "";
        });
        _storeLocation(_area, _city, _locality, _state, _postalCode);
      } else {
        setState(() {
          _area = "Not available";
          _city = "Not available";
          _locality = "Not available";
          _state = "Not available";
          _postalCode = "Not available";
        });
      }
    } catch (e) {
      //print("Error: $e");
      setState(() {
        _area = "Error getting location";
        _city = "Error getting location";
        _locality = "Error getting location";
        _state = "Error getting location";
        _postalCode = "Error getting location";
      });
    }
  }

  Future<void> _storeLocation(
    String area,
    String city,
    String locality,
    String state,
    String postalCode,
  ) async {
    QuerySnapshot snapshot =
        await db.collection('users').where('email', isEqualTo: "$email").get();
    if (snapshot.docs.isNotEmpty) {
      DocumentSnapshot snap = snapshot.docs.first;
      CollectionReference ref = snap.reference.collection('location');
      // QuerySnapshot userSnapshot =
      //     await ref.where('email', isEqualTo: email).get();
      QuerySnapshot locationSnapshot = await ref.get();
      if (locationSnapshot.docs.isEmpty) {
        await ref.add({
          'area': area,
          'city': city,
          'locality': locality,
          'state': state,
          'postalCode': postalCode,
        });
      } else {
        DocumentSnapshot locationDocument = locationSnapshot.docs.first;
        await locationDocument.reference.update({
          'area': area,
          'city': city,
          'locality': locality,
          'state': state,
          'postalCode': postalCode,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Area: $_area',
            ),
            Text(
              'City:$_city',
            ),
            Text(
              'Locality:$_locality',
            ),
            Text(
              'State:$_state',
            ),
            Text(
              'Postal Code:$_postalCode',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? position;

  late GoogleMapController googleMapController;

  Future<void> getCurrentLocation() async {
    final isGranted = await isLocationPermissionGranted();
    if (isGranted) {
      final isServiceEnabled = await checkGPSServiceEnable();
      if (isServiceEnabled) {
        Position p = await Geolocator.getCurrentPosition();
        position = p;
        print(position);
        setState(() {});
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestLocationPermission();
      if (result) {
        getCurrentLocation();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkGPSServiceEnable() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map Screen"),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
            target: LatLng(51.52312417943561, -0.1543398459953823), zoom: 17),
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        markers: <Marker>{
          Marker(
              markerId: const MarkerId('initial-postion'),
              position: const LatLng(51.52317758314869, -0.15431838832268546),
              infoWindow: InfoWindow(
                  title: 'Home',
                  onTap: () {
                    print('on tapped');
                  },),),
          if (position != null)
            Marker(
              markerId: const MarkerId('current-position'),
              position: LatLng(position!.latitude, position!.longitude),
              infoWindow: InfoWindow(
                title: 'Current Location',
                snippet: "${position!.latitude},${position!.longitude}"
              ),
            ),
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getCurrentLocation();
          if (position != null) {
            googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  zoom: 17,
                  target: LatLng(position!.latitude, position!.longitude),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Tap the button one more time"),
              ),
            );
          }
        },
        child: const Icon(Icons.gps_fixed_sharp),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../HomePage/home.dart';

class BusTrackingPage extends StatefulWidget {
  const BusTrackingPage({super.key});

  @override
  State<BusTrackingPage> createState() => _BusTrackingPageState();
}

class _BusTrackingPageState extends State<BusTrackingPage> {
  LocationData? _currentLocation;
  final Location _locationService = Location();
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  Future<void> _initLocationService() async {
    PermissionStatus permission = await _locationService.requestPermission();
    if (permission == PermissionStatus.granted) {
      final currentLocation = await _locationService.getLocation();
      setState(() {
        _currentLocation = currentLocation;
      });
      _locationService.onLocationChanged.listen((LocationData locationData) {
        _mapController.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(locationData.latitude!, locationData.longitude!),
          ),
        );
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _currentLocation != null
                ? CameraPosition(
              target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
              zoom: 15.0,
            )
                : const CameraPosition(
              target: LatLng(6.927079, 79.861244), // Colombo, Sri Lanka coordinates
              zoom: 12.0, // Zoom level
            ),
            mapType: MapType.normal, // Normal map type
            myLocationEnabled: true, // Enable user location
            zoomControlsEnabled: false, // Hide default zoom controls
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              height: 120.0, // Height of the top bar
              color: Colors.green,
              padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0.0), // Adjust the top padding for more space
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 10.0), // Space between icon and text
                  const Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

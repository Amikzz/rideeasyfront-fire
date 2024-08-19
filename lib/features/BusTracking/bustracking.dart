import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import for the Timer

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
  final List<Marker> _busMarkers = [];
  Timer? _timer; // Declare a Timer

  @override
  void initState() {
    super.initState();
    _initLocationService();
    _startLocationUpdates(); // Start updating bus locations
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
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
    } else {
      _showSnackBar('Location permission denied');
    }
  }

  void _startLocationUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchBusLocations(); // Fetch bus locations every 10 seconds
    });
  }

  Future<void> _fetchBusLocations() async {
    const url = "http://192.168.8.104:8000/api/location-get?status=active"; // Replace with your API endpoint
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> buses = json.decode(response.body);
        print(buses);

        if (buses.isEmpty) {
          _showSnackBar('No active buses found');
          return;
        }

        setState(() {
          _busMarkers.clear();
          for (var bus in buses) {
            final double latitude = double.parse(bus['latitude'].toString());
            final double longitude = double.parse(bus['longitude'].toString());

            if (latitude != null && longitude != null) {
              final LatLng position = LatLng(latitude, longitude);
              _busMarkers.add(
                Marker(
                  markerId: MarkerId(bus['bus_license_plate_no'].toString()),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Icon for a moving object
                  position: position,
                  infoWindow: InfoWindow(
                    title: 'Bus: ${bus['bus_license_plate_no']}',
                    snippet: 'Last Updated: ${bus['lastUpdateLocation']} ',
                  ),
                ),
              );
            } else {
              print('Invalid coordinates for bus: ${bus['bus_license_plate_no']}');
            }
          }
        });
      } else {
        _showSnackBar('Failed to fetch bus locations. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error fetching bus locations: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
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
            markers: Set<Marker>.of(_busMarkers), // Display bus markers
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

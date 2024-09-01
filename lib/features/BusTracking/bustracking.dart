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
  Marker? _selectedMarker; // Currently selected marker
  LatLng? _selectedMarkerPosition; // Position of the selected marker
  String? _lastUpdatedLocation; // Last updated location for the selected marker
  int? _validatedTickets; // Number of validated tickets for the selected marker

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
    const url = "http://192.168.8.103:8000/api/location-get?status=active"; // Replace with your API endpoint
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
            final String lastUpdated = bus['lastUpdateLocation'] ?? 'Unknown';

            if (latitude != null && longitude != null) {
              final LatLng position = LatLng(latitude, longitude);

              // Fetch the number of validated tickets for each bus
              _fetchValidatedTickets(bus['bus_license_plate_no']).then((validatedTickets) {
                // Determine the marker color based on the number of validated tickets
                BitmapDescriptor markerColor = BitmapDescriptor.defaultMarkerWithHue(
                  validatedTickets > 35 ? BitmapDescriptor.hueRed :
                  validatedTickets >= 20 ? BitmapDescriptor.hueYellow :
                  BitmapDescriptor.hueGreen,
                );

                setState(() {
                  _busMarkers.add(
                    Marker(
                      markerId: MarkerId(bus['bus_license_plate_no'].toString()),
                      icon: markerColor, // Dynamic icon color based on ticket count
                      position: position,
                      onTap: () {
                        setState(() {
                          _selectedMarker = Marker(
                            markerId: MarkerId(bus['bus_license_plate_no'].toString()),
                            icon: markerColor,
                            position: position,
                          );
                          _selectedMarkerPosition = position;
                          _lastUpdatedLocation = lastUpdated; // Set the last updated location
                          _validatedTickets = validatedTickets; // Set the validated tickets count
                        });
                      },
                    ),
                  );
                });
              });
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

  // Function to fetch the number of validated tickets for each bus
  Future<int> _fetchValidatedTickets(String busLicensePlate) async {
    const String apiUrl = "http://192.168.8.103:8000/api/get-validated-ticket"; // Replace with your actual endpoint
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'bus_license_plate_no': busLicensePlate}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['validated_tickets'] ?? 0; // Return the number of validated tickets
      } else {
        print('Failed to fetch validated tickets. Status code: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error fetching validated tickets: $e');
      return 0;
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
          if (_selectedMarker != null && _selectedMarkerPosition != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 50,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 50.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bus: ${_selectedMarker!.markerId.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Last Updated: ${_lastUpdatedLocation ?? 'Unknown'}'), // Display actual last updated location
                    Text('Validated Tickets: ${_validatedTickets ?? 0}'), // Display actual validated tickets
                  ],
                ),
              ),
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
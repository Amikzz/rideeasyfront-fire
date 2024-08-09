import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ride_easy/features/BusSeatReserve/comingsoon.dart';
import 'package:ride_easy/features/BusShedule/busshedule.dart';
import 'package:ride_easy/features/BusTracking/bustracking.dart';
import 'package:ride_easy/features/FeedbackPage/feedbackpage.dart';
import 'package:ride_easy/features/SupportPage/faqpage.dart';
import 'package:ride_easy/features/TicketBooking/ticketbooking.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../WelcomePage/welcome.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _cityName = 'Loading...'; // Default value
  String _userName = 'User'; // Default value

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _fetchUserName();
  }

  Future<void> _fetchLocation() async {
    try {
      // Check for location permission
      bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        setState(() {
          _cityName = 'Location services are disabled';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
          setState(() {
            _cityName = 'Location permission denied';
          });
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      // Convert position to city name
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _cityName = place.locality ?? 'Unknown city';
      });
    } catch (e) {
      setState(() {
        _cityName = 'Failed to get location';
      });
    }
  }

  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String _userId = user.uid;
      // Fetch user data from Firestore using _userId
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot snapshot = await firestore.collection('users').doc(_userId).get();
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _userName = data['firstName'] ?? 'User'; // Default to 'User' if firstName is null
      });
    }
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()), // Replace with your login page
      );
    } catch (e) {
      print('Error signing out: ${e.toString()}');
      // Handle sign out error here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Padding(
          padding: const EdgeInsets.only(top: 55, left: 25, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hello, $_userName', // This will be updated dynamically
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 70) // Adjust space to accommodate the dropdown
                  ],
                ),
              ),
              const SizedBox(), // Empty space
              PopupMenuButton<String>(
                icon: const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/360_F_65772719_A1UV5kLi5nCEWI0BNLLiFaBPEkUbv5Fv.jpg'),
                  radius: 30,
                ),
                onSelected: (value) {
                  if (value == 'logout') {
                    _logout();
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _cityName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Icon(Icons.location_on, color: Colors.green),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildButton(
                    context: context,
                    title: 'Bus Tracking',
                    targetPage: const BusTrackingPage(),
                    image: const AssetImage('assets/images/track.png'),
                  ),
                  _buildButton(
                    context: context,
                    title: 'Bus Schedule',
                    image: const AssetImage('assets/images/shedule.png'),
                    targetPage: const BusSchedulePage(),
                  ),
                  _buildButton(
                    context: context,
                    title: 'Ticket Booking',
                    image: const AssetImage('assets/images/ticket.png'),
                    targetPage: const TicketBookingPage(),
                  ),
                  _buildButton(
                    context: context,
                    title: 'Bus Seat Reserve',
                    image: const AssetImage('assets/images/seat.png'),
                    targetPage: const ComingSoonPage(),
                  ),
                  _buildButton(
                    context: context,
                    title: 'Support',
                    image: const AssetImage('assets/images/support.png'),
                    targetPage: const FAQPage(),
                  ),
                  _buildButton(
                    context: context,
                    title: 'FeedBack',
                    image: const AssetImage('assets/images/feedback.png'),
                    targetPage: const FeedbackPage(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 80,
              height: 80,
              child: ElevatedButton(
                onPressed: () {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.topSlide,
                    customHeader: const Icon(
                      Icons.warning,
                      size: 50,
                      color: Colors.orange,
                    ),
                    title: 'Don\'t Panic',
                    desc: 'Are you sure you want to call emergency contact?',
                    btnCancel: ElevatedButton(
                      onPressed: () {
                        // Call emergency contact
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('SOS'),
                    ),
                    btnOkOnPress: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                  ).show();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                ),
                child: const Text(
                  'Safety',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String title,
    required AssetImage image,
    required Widget targetPage,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shadowColor: Colors.green,
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 16,
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image: image, height: 100, width: 160),
          const SizedBox(height: 1),
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

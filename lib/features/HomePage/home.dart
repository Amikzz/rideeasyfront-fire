import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ride_easy/features/BusShedule/busshedule.dart';
import 'package:ride_easy/features/BusSheetBooking/destinationpage.dart';
import 'package:ride_easy/features/BusTracking/bustracking.dart';
import 'package:ride_easy/features/FeedbackPage/feedbackpage.dart';
import 'package:ride_easy/features/Profile/profilepage.dart';
import 'package:ride_easy/features/SupportPage/faqpage.dart';
import 'package:ride_easy/features/TicketBooking/ticketbooking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kommunicate_flutter/kommunicate_flutter.dart';
import 'package:ride_easy/features/WelcomePage/welcome.dart';


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

  Future<void> _showSafetyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red[50], // Light red background
          title: Center(
            child: Text(
              'Select Safety Issue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[900], // Dark red text
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.drive_eta_rounded, color: Colors.red[700], size: 30),
                  title: const Text(
                    'Driver related',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _sendSOSRequest('Driver related');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person_outline, color: Colors.red[700], size: 30),
                  title: const Text(
                    'Conductor related',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _sendSOSRequest('Conductor related');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.people_alt_outlined, color: Colors.red[700], size: 30),
                  title: const Text(
                    'Other passenger/s related',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _sendSOSRequest('Other passenger/s related');
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _sendSOSRequest(String issueType) async {
    try {
      // Get current user ID from Firebase Auth
      final String userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch user details from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final String firstName = userDoc['firstName'];
        final String lastName = userDoc['lastName'];
        final String idNumber = userDoc['idCardNo'];

        // Get current location
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled.');
        }

        LocationPermission permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
            throw Exception('Location permissions are denied');
          }
        }

        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        final double latitude = position.latitude;
        final double longitude = position.longitude;

        // Prepare data to be sent
        Map<String, dynamic> sosData = {
          'id_number': idNumber,
          'passenger_id': userId,
          'first_name': firstName,
          'last_name': lastName,
          'latitude': latitude,
          'longitude': longitude,
          'issue_type': issueType, // Add issue type to the request data
        };

        // Send SOS request to backend
        const String apiUrl = "http://192.168.8.103:8000/api/safety-button"; // Replace with your actual API endpoint
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(sosData),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SOS request sent successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send SOS request')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending SOS: $e')),
      );
    }
  }

  Future<void> _launchChatbot() async {
    try {
      // Prepare the conversation object with your Kommunicate app ID
      dynamic conversationObject = {
        'appId': '243c79d5281787463f0c33ba1582fef6', // Replace with your actual Kommunicate app ID
      };

      // Show chatbot in a dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Chat with Us',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: KommunicateFlutterPlugin.buildConversation(conversationObject),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error launching chatbot');
                      } else {
                        return const Text('Chatbot is ready');
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Close Chatbot'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print("Error launching chatbot: " + e.toString());
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
                padding: const EdgeInsets.all(8.0),
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
                    const SizedBox(width: 70) // Adjust space to accommodate the dropdown
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
                  } else if (value == 'profile') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
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
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
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
                        targetPage: const DestinationPage(),
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
                      _showSafetyDialog();
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
          Positioned(
            bottom: 35,
            right: 30,
            child: FloatingActionButton(
              onPressed: _launchChatbot,
              backgroundColor: Colors.green,
              child: const Icon(Icons.chat, color: Colors.white,),
            ),
          ),
        ],
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

// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:ride_easy/common/customappbar.dart';
import 'package:ride_easy/features/HomePage/home.dart';
import 'package:ride_easy/features/PaymentPage/payment.dart';

class BusSeatBookingPage extends StatefulWidget {
  final Map<String, dynamic> busDetails;

  const BusSeatBookingPage({super.key, required this.busDetails});

  @override
  _BusSeatBookingPageState createState() => _BusSeatBookingPageState();
}

class _BusSeatBookingPageState extends State<BusSeatBookingPage> {
  List<bool> reservedSeats = List.generate(54, (index) => false);
  final List<bool> selectedSeats = List.generate(54, (index) => false);

  int _adultCount = 0;
  int _childCount = 0;
  bool _showPaymentForm = false;
  // ignore: unused_field
  bool _paymentSuccessful = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchReservedSeats();
  }

  int get totalPassengers => _adultCount + _childCount;

  double get totalFare => (_adultCount * 200.0) + (_childCount * 100.0);

  bool canSelectSeat(int currentSelectedSeats) {
    return currentSelectedSeats < totalPassengers;
  }

  Future<void> _fetchReservedSeats() async {
    final url = Uri.parse('http://192.168.8.103:8000/api/check-seats');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'trip_id': widget.busDetails['tripId']}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check if booked_seats is not null and is a list
        if (responseData['booked_seats'] != null &&
            responseData['booked_seats'] is List) {
          final List<dynamic> bookedSeats = responseData['booked_seats'];

          setState(() {
            for (var seatNumber in bookedSeats) {
              // Handle both int and String seat numbers
              int seatIndex;
              if (seatNumber is int) {
                seatIndex = seatNumber - 1;
              } else if (seatNumber is String) {
                seatIndex = int.parse(seatNumber) - 1;
              } else {
                continue; // Skip invalid seat numbers
              }

              reservedSeats[seatIndex] = true;
            }
          });
        } else {
          // Handle case where booked_seats is null or not a valid list
          setState(() {
            // Ensure all seats are marked as not reserved
            reservedSeats = List<bool>.filled(reservedSeats.length, false);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch reserved seats.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }

  }

  Future<void> bookSeats({
    required BuildContext context, // Include BuildContext to show SnackBar
    required String busLicensePlateNo,
    required String passengerId,
    required String tripId,
    required String startLocation,
    required String endLocation,
    required String date,
    required String departureTime,
    required int noOfAdults,
    required int noOfChildren,
    required List<String> seatNumbers,
  }) async {
    const String url = 'http://192.168.8.103:8000/api/seat-booking'; // Replace with your backend URL

    try {
      // Prepare request body
      Map<String, dynamic> requestBody = {
        'bus_license_plate_no': busLicensePlateNo,
        'passenger_id': passengerId,
        'trip_id': tripId,
        'start_location': startLocation,
        'end_location': endLocation,
        'date': date,
        'departure_time': departureTime,
        'no_of_adults': noOfAdults,
        'no_of_children': noOfChildren,
        'seat_numbers': jsonEncode(seatNumbers), // Convert seat numbers list to JSON
      };

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Check the response status code
      if (response.statusCode == 200) {
        // Decode the response body
        final responseBody = jsonDecode(response.body);
        _showSnackBar(context, 'Seats successfully booked!', Colors.blueAccent);
      } else if (response.statusCode == 422) {
        _showSnackBar(context, 'Validation error: ${jsonDecode(response.body)['error']}', Colors.red);
      } else {
        _showSnackBar(context, 'Error: ${jsonDecode(response.body)['error']}', Colors.red);
      }
    } catch (e) {
      _showSnackBar(context, 'An unexpected error occurred: $e', Colors.red);
    }
  }

  // Helper function to show SnackBar
    void _showSnackBar(BuildContext context, String message, Color color) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: Duration(seconds: 3),
        ),
      );
    }
    
  void _scrollToForm() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    });
  }


  void _processPayment() async {
    setState(() {
      _paymentSuccessful = true;
    });

    if (_paymentSuccessful) {
      try {
        // Get the current user from Firebase Authentication
        User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          // Use the Firebase user ID as the passenger ID
          String passengerId = currentUser.uid;

          // Proceed with booking the seats
          await bookSeats(
            context: context,
            busLicensePlateNo: widget.busDetails['license'],
            passengerId: passengerId, // Set the Firebase user ID
            tripId: widget.busDetails['tripId'],
            startLocation: widget.busDetails['from'],
            endLocation: widget.busDetails['to'],
            date: widget.busDetails['date'],
            departureTime: widget.busDetails['departureTime'],
            noOfAdults: _adultCount,
            noOfChildren: _childCount,
            seatNumbers: selectedSeats
                .asMap() // Convert List<bool> to a map
                .entries // Get the entries (index and value pairs)
                .where((entry) => entry.value) // Filter to only selected seats
                .map((entry) =>
                (entry.key + 1).toString()) // Convert to seat numbers (1-based index)
                .toList(), // Convert to List<String>
          );
        } else {
          // If the user is not signed in, show an error
          _showSnackBar(context, 'No user is currently signed in. Please log in first.', Colors.red);
        }
      } catch (e) {
        // Handle any errors that occur while fetching the user ID or booking the seats
        _showSnackBar(context, 'An error occurred: $e', Colors.red);
      }
    } else {
      // Handle payment failure
      _showSnackBar(context, 'Payment failed. Please try again.', Colors.red);
  }


  // Show the payment successful dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Successful'),
          content: const Text('Your payment has been processed successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentCompletePage(
                      busDetails: widget.busDetails,
                      totalFare: totalFare,
                      reservedSeats: selectedSeats
                          .asMap() // Convert List<bool> to a map
                          .entries // Get the entries (index and value pairs)
                          .where((entry) =>
                              entry.value) // Filter to only selected seats
                          .map((entry) =>
                              entry.key +
                              1) // Convert to seat numbers (1-based index)
                          .toList(), // Convert to List<int>
                    ),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: ClipPath(
          clipper: CustomAppBar(),
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()),
                        );
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Bus Tracking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
                const SizedBox(width: 50),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Bus: ${widget.busDetails['license']} | ${widget.busDetails['from']} to ${widget.busDetails['to']}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    const Text(
                      'Fare per Adult: LKR 200.00',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const Text(
                      'Fare per Child: LKR 100.00',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        PassengerCount(
                          title: 'Adult',
                          count: _adultCount,
                          onAdd: () => setState(() => _adultCount++),
                          onRemove: () => setState(() {
                            if (_adultCount > 0) _adultCount--;
                          }),
                        ),
                        PassengerCount(
                          title: 'Child',
                          count: _childCount,
                          onAdd: () => setState(() => _childCount++),
                          onRemove: () => setState(() {
                            if (_childCount > 0) _childCount--;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Total Passengers: $totalPassengers',
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            'Total Fare: LKR ${totalFare.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        children: [
                          SizedBox(height: 70),
                          Icon(Icons.keyboard_arrow_right,
                              size: 30, color: Colors.green),
                          SizedBox(height: 560),
                          Icon(Icons.keyboard_arrow_left,
                              size: 30, color: Colors.green),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 300,
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: List.generate(13, (rowIndex) {
                            // 13 rows total
                            if (rowIndex == 12) {
                              // Last row with 6 seats
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: buildSeat(index + rowIndex * 4),
                                  );
                                }),
                              );
                            } else {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        buildSeat(
                                            rowIndex * 4), // Left side seats
                                        const SizedBox(width: 8),
                                        buildSeat(rowIndex * 4 + 1),
                                      ],
                                    ),
                                    const SizedBox(
                                        width: 20), // Space in the middle
                                    Row(
                                      children: [
                                        buildSeat(rowIndex * 4 +
                                            2), // Right side seats
                                        const SizedBox(width: 8),
                                        buildSeat(rowIndex * 4 + 3),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 60,
                    child: Image.asset(
                      'assets/images/wheel.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip ID: ${widget.busDetails['tripId']}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'From: ${widget.busDetails['from']}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'To: ${widget.busDetails['to']}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${widget.busDetails['date']}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Departure Time: ${widget.busDetails['departureTime']}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Arrival Time: ${widget.busDetails['arrivalTime']}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bus License Plate: ${widget.busDetails['license']}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Selected Seats:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      selectedSeats
                          .asMap()
                          .entries
                          .where((entry) => entry.value)
                          .map((entry) => 'Seat ${entry.key + 1}')
                          .join(', '),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total Price: LKR ${totalFare.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_showPaymentForm)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showPaymentForm = true;
                    });
                    _scrollToForm();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Proceed to Payment',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (_showPaymentForm)
              Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'LKR $totalFare',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'How would you like to pay?',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Image.asset('assets/images/Visa.png',
                              width: 50, height: 50),
                          iconSize: 50,
                          onPressed: () {
                            // Process Visa payment
                          },
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: Image.asset('assets/images/Ewallet.jpeg',
                              width: 50, height: 50),
                          iconSize: 50,
                          onPressed: () {
                            // Process eWallet payment
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'CARD NUMBER',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'CARD HOLDER NAME',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: const Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'EXPIRATION DATE',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 50),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'CONFIRM PAYMENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSeat(int seatIndex) {
    int selectedSeatCount = selectedSeats.where((seat) => seat).length;
    return Seat(
      isReserved: reservedSeats[seatIndex],
      isSelected: selectedSeats[seatIndex],
      onSelect: () {
        if (!selectedSeats[seatIndex]) {
          if (canSelectSeat(selectedSeatCount)) {
            setState(() {
              selectedSeats[seatIndex] = true;
            });
          }
        } else {
          setState(() {
            selectedSeats[seatIndex] = false;
          });
        }
      },
      seatNumber: seatIndex + 1,
    );
  }
}

class PassengerCount extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const PassengerCount({
    super.key,
    required this.title,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '$count',
              style: const TextStyle(fontSize: 18),
            ),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }
}

class Seat extends StatelessWidget {
  final bool isReserved;
  final bool isSelected;
  final VoidCallback onSelect;
  final int seatNumber;

  const Seat({
    super.key,
    required this.isReserved,
    required this.isSelected,
    required this.onSelect,
    required this.seatNumber,
  });

  @override
  Widget build(BuildContext context) {
    Color seatColor;
    if (isReserved) {
      seatColor = Colors.grey; // Reserved seat color
    } else if (isSelected) {
      seatColor = Colors.green; // Selected seat color
    } else {
      seatColor = Colors.blue; // Available seat color
    }

    return GestureDetector(
      onTap: isReserved ? null : onSelect,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            seatNumber.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentCompletePage extends StatefulWidget {
  final Map<String, dynamic> busDetails;
  final double totalFare;
  final List<int> reservedSeats; // List of reserved seat numbers

  const PaymentCompletePage({
    super.key,
    required this.busDetails,
    required this.totalFare,
    required this.reservedSeats,
  });

  @override
  _PaymentCompletePageState createState() => _PaymentCompletePageState();
}

class _PaymentCompletePageState extends State<PaymentCompletePage> {
  List<String>? ticketIds; // Variable to store fetched ticket IDs
  bool isLoading = true; // Variable to track loading state

  @override
  void initState() {
    super.initState();
    _fetchTicketIds(); // Fetch ticket IDs when the widget is initialized
  }

  Future<void> _fetchTicketIds() async {
    // Get the current user ID from Firebase
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case where the user is not logged in
      print('No user is logged in.');
      return;
    }

    try {
      // Fetch ticket IDs from the server
      List<String>? ids = await fetchTicketIds(
        tripId: widget.busDetails['tripId'],
        passengerId: user.uid, // Use the Firebase user's UID
        seatNumbers: widget.reservedSeats.map((seat) => seat.toString()).toList(),
      );

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          ticketIds = ids; // Update state with fetched ticket IDs
          isLoading = false; // Set loading to false after fetching
        });
      }
    } catch (e) {
      // Handle any unexpected errors
      print('An unexpected error occurred: $e'); // Print the error for debugging

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          isLoading = false; // Set loading to false in case of error
        });
      }
    }
  }

  Future<List<String>?> fetchTicketIds({
    required String tripId,
    required String passengerId,
    required List<String> seatNumbers,
  }) async {
    const String url = 'http://192.168.8.103:8000/api/get-seat-ticketID';

    try {
      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'trip_id': tripId,
        'seat_numbers': jsonEncode(seatNumbers), // Correctly encode the seat numbers as JSON
        'passenger_id': passengerId,
      };

      print('Sending request to $url with body: $requestBody');

      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Received response with status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check if the response status code is OK (200)
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Ensure the response body is a map and contains 'ticket_ids' key
        if (responseBody is Map<String, dynamic> && responseBody.containsKey('ticket_ids')) {
          List<dynamic> ticketIdsDynamic = responseBody['ticket_ids'];

          // Ensure all elements in the list are strings
          List<String> ticketIds = ticketIdsDynamic.map((id) => id.toString()).toList();
          print('Fetched ticket IDs: $ticketIds');
          return ticketIds;
        } else {
          print('Error: Unexpected response format. Expected a map with key "ticket_ids".');
          return null;
        }
      } else {
        String errorMessage = jsonDecode(response.body)['error'];
        print('Error: $errorMessage');
        return null;
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: ClipPath(
          clipper: CustomAppBar(),
          child: Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        ); // Navigate back
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Payment Confirmation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
                const SizedBox(width: 50), // Adjust spacing as needed
              ],
            ),
          ),
        ),
      ),
      body: isLoading // Show loading indicator while fetching ticket IDs
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 100, color: Colors.green),
                const SizedBox(height: 24),
                const Text(
                  'Thank you!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Your payment was successful. Please take a screenshot of this and show it to the Conductor when you get into the bus.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Here are your trip details:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CustomTicketWidget(
                  width: 250,
                  height: 450, // Adjusted height
                  isCornerRounded: true,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.green,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ticket IDs: ${ticketIds?.join(", ") ?? "Loading..."}', // Display fetched ticket IDs
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Trip ID: ${widget.busDetails['tripId']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Bus: ${widget.busDetails['license']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Date: ${widget.busDetails['date']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'From: ${widget.busDetails['from']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'To: ${widget.busDetails['to']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Departure Time: ${widget.busDetails['departureTime']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Arrival Time: ${widget.busDetails['arrivalTime']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Reserved Seats: ${widget.reservedSeats.join(", ")}', // Display reserved seat numbers
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.white,
                          child: Center(
                            child: Text(
                              'Total Fare: LKR ${widget.totalFare}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Return to Home',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

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
  final List<bool> reservedSeats = List.generate(54, (index) => false);
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
    reservedSeats[5] = true;
    reservedSeats[10] = true;
    reservedSeats[15] = true;
  }

  int get totalPassengers => _adultCount + _childCount;

  double get totalFare => (_adultCount * 200.0) + (_childCount * 100.0);

  bool canSelectSeat(int currentSelectedSeats) {
    return currentSelectedSeats < totalPassengers;
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

  void _processPayment() {
    setState(() {
      _paymentSuccessful = true;
    });

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
                        'Bus: ${widget.busDetails['bus_license_plate_no']} | ${widget.busDetails['start_location']} to ${widget.busDetails['end_location']}',
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
                          'Trip ID: ${widget.busDetails['trip_id']}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'From: ${widget.busDetails['start_location']}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'To: ${widget.busDetails['end_location']}',
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
                          'Departure Time: ${widget.busDetails['departure_time']}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Arrival Time: ${widget.busDetails['arrival_time']}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bus License Plate: ${widget.busDetails['bus_license_plate_no']}',
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

class PaymentCompletePage extends StatelessWidget {
  final Map<String, dynamic> busDetails;
  final double totalFare;
  final List<int> reservedSeats; // Changed to List<int>

  const PaymentCompletePage({
    super.key,
    required this.busDetails,
    required this.totalFare,
    required this.reservedSeats,
  });

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
                                builder: (context) =>
                                    const HomePage())); // Navigate back
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
      body: SingleChildScrollView(
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
                  'Your payment was successful.',
                  style: TextStyle(fontSize: 18),
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
                                'Trip ID: ${busDetails['trip_id']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'From: ${busDetails['start_location']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'To: ${busDetails['end_location']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Departure Time: ${busDetails['departure_time']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Arrival Time: ${busDetails['arrival_time']}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Reserved Seats: ${reservedSeats.join(", ")}', // Now displaying the seat indices directly
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
                              'Total Fare: LKR $totalFare',
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

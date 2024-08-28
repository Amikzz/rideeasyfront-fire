import 'package:flutter/material.dart';
import 'package:ride_easy/common/customappbar.dart';
import 'package:ride_easy/features/BusSheetBooking/busseatpage.dart';
import 'package:ride_easy/features/HomePage/home.dart';

class DestinationPage extends StatefulWidget {
  const DestinationPage({super.key});

  @override
  State<DestinationPage> createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  String _selectedFromLocation = 'Location 1';
  String _selectedToLocation = 'Location 2';
  DateTime _selectedDate = DateTime.now();

  final List<String> _locations = ['Location 1', 'Location 2', 'Location 3'];
  final List<Map<String, dynamic>> _busList = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _searchBuses() {
    setState(() {
      _busList.clear();
      _busList.add({
        'tripId': 'TRIP1234',
        'from': _selectedFromLocation,
        'to': _selectedToLocation,
        'license': 'ABC-1234',
        'departureTime': '10:00 AM',
        'arrivalTime': '12:00 PM',
        'date': "${_selectedDate.toLocal()}".split(' ')[0],
      });
      _busList.add({
        'tripId': 'TRIP5678',
        'from': _selectedFromLocation,
        'to': _selectedToLocation,
        'license': 'XYZ-5678',
        'departureTime': '12:00 PM',
        'arrivalTime': '2:00 PM',
        'date': "${_selectedDate.toLocal()}".split(' ')[0],
      });
      _busList.add({
        'tripId': 'TRIP9101',
        'from': _selectedFromLocation,
        'to': _selectedToLocation,
        'license': 'LMN-9101',
        'departureTime': '2:00 PM',
        'arrivalTime': '4:00 PM',
        'date': "${_selectedDate.toLocal()}".split(' ')[0],
      });
    });
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
                            builder: (context) => const HomePage(),
                          ),
                        ); // Navigate back
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Bus Seat Booking',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Where Do You Want To Go?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
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
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'From',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<String>(
                              value: _selectedFromLocation,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedFromLocation = newValue!;
                                });
                              },
                              items: _locations.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 38.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.swap_vert,
                                color: Colors.white),
                            onPressed: () {
                              setState(() {
                                final temp = _selectedFromLocation;
                                _selectedFromLocation = _selectedToLocation;
                                _selectedToLocation = temp;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'To',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<String>(
                              value: _selectedToLocation,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedToLocation = newValue!;
                                });
                              },
                              items: _locations.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'DATE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => _selectDate(context),
                          child: Text(
                            "${_selectedDate.toLocal()}".split(' ')[0],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchBuses,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'SEARCH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_busList.isNotEmpty)
              ..._busList.map((bus) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BusSeatBookingPage(busDetails: bus),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('${bus['from']} to ${bus['to']}'),
                      subtitle: Text(
                        'Trip ID: ${bus['tripId']}\nLicense Plate: ${bus['license']}\nDeparture Time: ${bus['departureTime']}\nArrival Time: ${bus['arrivalTime']}\nDate: ${bus['date']}',
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ride_easy/features/HomePage/home.dart';

class DonePage extends StatelessWidget {
  const DonePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Text(
                'Thank You!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Thank you for registering with RideEasy',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 55),
              Image.asset('assets/images/Done.gif'),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, // Make button take full width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Go to Home', style: TextStyle(color: Colors.white)),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

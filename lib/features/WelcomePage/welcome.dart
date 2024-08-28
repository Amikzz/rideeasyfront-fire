// ignore_for_file: library_private_types_in_public_api, unused_import

import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
import 'package:ride_easy/features/HomePage/home.dart';
import 'package:ride_easy/features/LoginPage/login.dart';
import 'package:ride_easy/features/SignUpPage/Signup.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _currentIndex = 0;

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
              const SizedBox(height: 50),
              const Text(
                'Hello, nice to meet you!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              const Text(
                'Get a new experience',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'For Your Public',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Transportation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // CarouselSlider(
              //   options: CarouselOptions(
              //     height: 320,
              //     viewportFraction: 1,
              //     autoPlay: true,
              //     onPageChanged: (index, reason) {
              //       setState(() {
              //         _currentIndex = index;
              //       });
              //     },
              //   ),
              //   items: [
              //     Container(
              //       decoration:
              //           BoxDecoration(borderRadius: BorderRadius.circular(20)),
              //       child: ClipRRect(
              //         borderRadius: BorderRadius.circular(20),
              //         child: const Image(
              //           image: AssetImage('assets/images/welcome.gif'),
              //           fit: BoxFit.contain,
              //         ),
              //       ),
              //     ),
              //     Container(
              //       decoration:
              //           BoxDecoration(borderRadius: BorderRadius.circular(20)),
              //       child: ClipRRect(
              //         borderRadius: BorderRadius.circular(20),
              //         child: const Image(
              //           image: AssetImage('assets/images/welcome2.gif'),
              //           fit: BoxFit.contain,
              //         ),
              //       ),
              //     ),
              //     Container(
              //       decoration:
              //           BoxDecoration(borderRadius: BorderRadius.circular(20)),
              //       child: ClipRRect(
              //         borderRadius: BorderRadius.circular(20),
              //         child: const Image(
              //           image: AssetImage('assets/images/welcome3.gif'),
              //           fit: BoxFit.contain,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    height: 8,
                    width: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color:
                          _currentIndex == index ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, // Make button take full width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
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
                      Text('Login', style: TextStyle(color: Colors.white)),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  // Handle the onTap event
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()));
                },
                child: const Text(
                  ' Or Create My Account',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ride_easy/common/customappbar.dart';
import 'package:ride_easy/features/HomePage/home.dart';
import 'package:ride_easy/features/SupportPage/formpage.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final questions = [
    {
      'question': 'How can I book a bus ticket?',
      'answer':
          'You can book a bus ticket by selecting your destination, choosing a bus, and making a payment through our secure payment gateway.'
    },
    {
      'question': 'How can I check the bus schedule?',
      'answer':
          'The bus schedule can be checked by navigating to the "Bus Schedule" section in the app, where you can see the departure and arrival times for all routes.'
    },
    {
      'question': 'What should I do in case of an emergency?',
      'answer':
          'In case of an emergency, you can use the "Emergency" button in the app to contact our support team or local emergency services directly.'
    },
    {
      'question': 'How does the bus tracking feature work?',
      'answer':
          'The bus tracking feature allows you to see the real-time location of your bus on a map, ensuring you know exactly when it will arrive at your stop.'
    },
    {
      'question': 'What in-built games are available in the app?',
      'answer':
          'Our app offers a variety of in-built games that you can play while waiting for your bus or during your journey. Simply navigate to the "Games" section to start playing.'
    },
    {
      'question': 'Can I cancel my bus ticket?',
      'answer':
          'Yes, you can cancel your bus ticket through the "My Bookings" section in the app. Cancellation policies and refunds depend on the terms and conditions of the bus operator.'
    },
    {
      'question': 'How do I contact customer support?',
      'answer':
          'You can contact customer support by using the "Contact Us" section in the app, where you will find our support hotline and email address.'
    },
  ];

  void _navigateToSupportForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SupportFormPage()),
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
                      'FAQ',
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ExpansionTile(
              title: const Text('General Information'),
              children: questions.map((q) {
                return ListTile(
                  title: Text(q['question']!),
                  subtitle: Text(q['answer']!),
                );
              }).toList(),
            ),
            const ExpansionTile(
              title: Text('Troubleshooting and Problem-Solving'),
              children: [
                ListTile(
                  title: Text('I am having trouble logging in.'),
                  subtitle: Text(
                      'Try resetting your password or contacting customer support for assistance.'),
                ),
                ListTile(
                  title: Text('The app is crashing.'),
                  subtitle: Text(
                      'Try closing and reopening the app, or contacting customer support for assistance.'),
                ),
              ],
            ),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Customer Support and Contact Information'),
                    subtitle: Text(
                        'For assistance, you can contact us at the following numbers and email addresses:'),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('+94 78 458 7856'),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('+94 76 865 4596'),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('support@rideeasy.lk'),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text('contactus@rideeasy.lk'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToSupportForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Fill Support Form',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

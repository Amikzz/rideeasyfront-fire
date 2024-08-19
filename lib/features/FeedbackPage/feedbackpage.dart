import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ride_easy/common/constant.dart';
import 'package:ride_easy/common/customappbar.dart';
import 'package:ride_easy/features/HomePage/home.dart';
import 'package:ride_easy/models/reviewModel.dart';
import 'package:ride_easy/widgets/custom_rating_bar.dart'; // Import the custom rating bar
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedbackPage> {
  bool isMore = false;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();
  double _rating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  void _addReview() async {
    try {
      // Get the current user's ID
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        // Fetch the user's first name from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

        String? firstName = userDoc.get('firstName');

        if (firstName != null) {
          // Create the review data
          Map<String, dynamic> reviewData = {
            'user_id': firstName, // Use the user's first name
            'review': _commentController.text,
            'rating': _rating,
            'bus_license': _licenseNumberController.text,
          };

          // Send the review data to the Laravel backend
          final response = await http.post(
            Uri.parse('http://192.168.8.104:8000/api/review-post'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(reviewData),
          );

          if (response.statusCode == 200) {
            setState(() {
              reviewList.add(Review(
                name: firstName, // Use the user's first name in the local list as well
                imageUrl: 'https://example.com/user_image.png', // Placeholder URL
                date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}',
                comment: _commentController.text,
                rating: _rating,
                licenseNumber: _licenseNumberController.text,
              ));
              _commentController.clear();
              _licenseNumberController.clear();
              _rating = 0;
            });

            Navigator.of(context).pop(); // Close the dialog after adding the review
          } else {
            // Handle error with SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to submit review: ${response.body}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('First name not found in Firestore')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID is null')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding review: $e')),
      );
    }
  }


  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[200], // Set background color to grey
          contentPadding: const EdgeInsets.all(16.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share your feedback',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Add a comment',
                  border: OutlineInputBorder(),
                ),
                maxLength: 500, // Optional: limit the length of the comment
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _licenseNumberController,
                decoration: const InputDecoration(
                  labelText: 'Bus License Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              CustomRatingBar(
                initialRating: _rating,
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _commentController.clear(); // Clear the comment controller
                _licenseNumberController
                    .clear(); // Clear the license number controller
                setState(() {
                  _rating = 0; // Clear the rating
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                if (_validateInputs()) {
                  _addReview();
                } else {
                  // Optionally, show an error message if validation fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields and provide a rating.'),
                    ),
                  );
                }
              },
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _validateInputs() {
    // Check if the comment is empty
    if (_commentController.text.isEmpty) {
      return false;
    }

    // Check if the license number is empty
    if (_licenseNumberController.text.isEmpty) {
      return false;
    }

    // Check if the rating is zero
    if (_rating <= 0) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                      'Feedback Page',
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
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                final review = reviewList[index];
                return ReviewUI(
                  imageUrl: review.imageUrl ?? '', // Provide a default value
                  name: review.name ?? 'Unknown', // Provide a default value
                  date:
                      review.date ?? 'Unknown date', // Provide a default value
                  comment:
                      review.comment ?? 'No comment', // Provide a default value
                  onTap: () => setState(() {
                    isMore = !isMore;
                  }),
                  isLess: isMore,
                  rating: review.rating ?? 0.0,
                  licenseNumber: review.licenseNumber ??
                      'Unknown', // Provide a default value
                );
              },
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: reviewList.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: _showReviewDialog,
              child: const Text(
                'Add Review',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewUI extends StatelessWidget {
  final String imageUrl, name, date, comment, licenseNumber;
  final VoidCallback onTap;
  final bool isLess;
  final double rating;

  const ReviewUI({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.date,
    required this.comment,
    required this.onTap,
    required this.isLess,
    required this.rating,
    required this.licenseNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 45.0,
                width: 45.0,
                margin: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(44.0),
                ),
              ),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                date,
                style: const TextStyle(fontSize: 18),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'License Number: $licenseNumber',
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onTap,
            child: isLess
                ? Text(
                    comment,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  )
                : Text(
                    comment,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
          ),
        ],
      ),
    );
  }
}

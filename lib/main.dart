// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:ride_easy/features/HomePage/home.dart';
import 'package:ride_easy/features/WelcomePage/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while checking the auth state
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Handle any errors that occur while checking authentication
          return Center(child: Text('Something went wrong: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          // User is signed in
          return const HomePage();
        } else {
          // User is not signed in
          return const WelcomePage();
        }
      },
    );
  }
}

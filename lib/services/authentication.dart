import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up
  Future<String> signUp(String email, String password, String firstName, String lastName, String address, String idCardNo, DateTime dob, String phoneNo) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //adding user to firestore
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'uid': _auth.currentUser!.uid,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'address': address,
        'idCardNo': idCardNo,
        'dob': dob,
        'phoneNo': phoneNo,
      });
      return 'Successfully signed up!';
    } on FirebaseAuthException catch (e) {
      // Map specific FirebaseAuthException codes to user-friendly messages
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      } else {
        return 'An error occurred. Please try again.';
      }
    } catch (e) {
      // Handle any other types of errors
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }

  // Sign in
  Future<String> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Successfully signed in!';
    } on FirebaseAuthException catch (e) {
      // Map specific FirebaseAuthException codes to user-friendly messages
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      } else {
        return 'An error occurred. Please try again.';
      }
    } catch (e) {
      // Handle any other types of errors
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }

  //is user signed up
  Future<bool> isUserSignedIn() async {
    var user = _auth.currentUser;
    return user != null;
  }
}

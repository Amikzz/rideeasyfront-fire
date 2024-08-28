import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ride_easy/common/customappbar.dart';
import 'package:ride_easy/features/Profile/profilepage.dart';
import 'package:ride_easy/features/WelcomePage/welcome.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController lane1Controller = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        firstNameController.text = data['firstName'] ?? '';
        lastNameController.text = data['lastName'] ?? '';
        phoneNumberController.text = data['phoneNo'] ?? '';
        lane1Controller.text = data['address'] ?? '';
        setState(() {}); // Refresh UI with loaded data
      }
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneNumber = value.trim();
    if (phoneNumber.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phoneNumber)) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final phoneNumberError = _validatePhoneNumber(phoneNumberController.text);
      if (phoneNumberError != null) {
        _showSnackBar(phoneNumberError);
        return;
      }

      try {
        await _firestore.collection('users').doc(user.uid).update({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'phoneNo': phoneNumberController.text,
          'address': lane1Controller.text,
          // Add profileImageUrl if you implement profile picture updates
        });

        // Show success message
        _showSnackBar('Profile updated successfully');
      } catch (e) {
        // Show error message
        _showSnackBar('Failed to update profile: $e');
      }

      // Reload user data to reflect changes
      await _loadUserData();
    }
  }


  Future<void> _deleteUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Delete Firestore document
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete Firebase Authentication user
        await user.delete();

        // Show success message and redirect to a different page or logout
        _showSnackBar('Account deleted successfully');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomePage(), // Or navigate to login page
          ),
        );
      } catch (e) {
        // Show error message
        _showSnackBar('Failed to delete account: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context, String title, Widget content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit $title',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                content,
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _updateUserData();
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteAccount() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Account Deletion'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteUser();
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
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Text(
                      'Edit Profile',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Row (non-editable)
              ListTile(
                title: const Text('Email',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  _auth.currentUser?.email ?? '',
                  style: const TextStyle(fontSize: 18),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              const Divider(),

              // First Name Row
              ListTile(
                title: const Text('First Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text(firstNameController.text.isEmpty
                    ? 'Enter your first name'
                    : firstNameController.text,
                    style: const TextStyle(fontSize: 18)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showEditBottomSheet(
                    context,
                    'First Name',
                    TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
              const Divider(),

              // Last Name Row
              ListTile(
                title: const Text('Last Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text(lastNameController.text.isEmpty
                    ? 'Enter your last name'
                    : lastNameController.text,
                    style: const TextStyle(fontSize: 18)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showEditBottomSheet(
                    context,
                    'Last Name',
                    TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
              const Divider(),

              // Phone Number Row
              ListTile(
                title: const Text('Phone Number',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text(phoneNumberController.text.isEmpty
                    ? 'Enter your phone number'
                    : phoneNumberController.text,
                    style: const TextStyle(fontSize: 18)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showEditBottomSheet(
                    context,
                    'Phone Number',
                    TextField(
                      controller: phoneNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
              const Divider(),

              // Address Row
              ListTile(
                title: const Text('Address',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text(lane1Controller.text.isEmpty
                    ? 'Enter your address'
                    : lane1Controller.text,
                    style: const TextStyle(fontSize: 18)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showEditBottomSheet(
                    context,
                    'Address',
                    TextField(
                      controller: lane1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
              const Divider(),

              // Delete Account Button at the Bottom
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  _confirmDeleteAccount();
                },
                child: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

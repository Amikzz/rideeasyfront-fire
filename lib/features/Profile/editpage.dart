// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:ride_easy/common/customappbar.dart';
import 'package:ride_easy/features/Profile/profilepage.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController firstNameController =
      TextEditingController(text: 'Mahith');
  final TextEditingController lastNameController =
      TextEditingController(text: 'Sheshan');
  final TextEditingController emailController =
      TextEditingController(text: 'mahith1@icloud.com');
  final TextEditingController genderController =
      TextEditingController(text: 'MALE');
  final TextEditingController phoneNumberController =
      TextEditingController(text: '0771234567');
  final TextEditingController lane1Controller =
      TextEditingController(text: 'No 123, Example Lane');
  final TextEditingController postalCodeController =
      TextEditingController(text: '12345');
  final TextEditingController cityController =
      TextEditingController(text: 'Colombo');
  final TextEditingController regionController =
      TextEditingController(text: 'Western Province');

  void _showEditBottomSheet(
      BuildContext context, String title, Widget content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled:
          true, // This line allows the bottom sheet to take full height if needed
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            // This ensures the content inside is scrollable
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
                    // Add save functionality
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
                        ); // Navigate back
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
                const SizedBox(width: 50), // Adjust spacing as needed
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
              const SizedBox(height: 16),

              // Centered Profile Picture Row
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          'https://avatars.githubusercontent.com/u/210413'), // Replace with user's actual image
                    ),
                    TextButton(
                      onPressed: () {
                        // Add functionality to edit photo
                      },
                      child: const Text(
                        'Change Photo',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Email Row
              ListTile(
                title: const Text('Email',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: const Text(
                  'mahith1@icloud.com',
                  style: TextStyle(fontSize: 18),
                ), // Replace with user's email
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showEditBottomSheet(
                    context,
                    'Email',
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                },
              ),
              const Divider(),

              // Name Row
              ListTile(
                title: const Text('Name',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: const Text('Mahith Sheshan',
                    style: TextStyle(fontSize: 18)), // Replace with user's name
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showEditBottomSheet(
                    context,
                    'Name',
                    Column(
                      children: [
                        TextField(
                          controller: firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(),

              // Phone Number Row
              ListTile(
                title: const Text('Phone Number',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: const Text('0771234567',
                    style: TextStyle(
                        fontSize: 18)), // Replace with user's phone number
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

              // Gender Row
              ListTile(
                title: const Text('Gender',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: const Text('MALE',
                    style:
                        TextStyle(fontSize: 18)), // Replace with user's gender
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showEditBottomSheet(
                    context,
                    'Gender',
                    TextField(
                      controller: genderController,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
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
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: const Text('Colombo',
                    style:
                        TextStyle(fontSize: 18)), // Replace with user's address
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showEditBottomSheet(
                    context,
                    'Address',
                    Column(
                      children: [
                        TextField(
                          controller: lane1Controller,
                          decoration: const InputDecoration(
                            labelText: 'Lane 1',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: postalCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Postal Code',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: cityController,
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: regionController,
                          decoration: const InputDecoration(
                            labelText: 'Region',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
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
                  // Add functionality to delete account
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

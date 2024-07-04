import 'package:flutter/material.dart';
import 'dart:io';

class UserDetailScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User ID: ${user['user_id']}'),
              Text('Name: ${user['name']}'),
              Text('Father\'s Name: ${user['father_name']}'),
              Text('Address: ${user['address']}'),
              Text('Aadhar No: ${user['aadhar_no']}'),
              Text('Phone No: ${user['phone_no']}'),
              Text('Group ID: ${user['group_id']}'),
              const SizedBox(height: 20),
              const Text('Photos:', style: TextStyle(fontWeight: FontWeight.bold)),
              if (user['photo'] != null)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Image.file(File(user['photo'])),
                  ],
                ),
              if (user['id_front_photo'] != null)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.file(File(user['id_front_photo'])),
                  ],
                ),
              if (user['id_back_photo'] != null)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.file(File(user['id_back_photo'])),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

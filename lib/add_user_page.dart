import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dart:io';
import 'camera_screen.dart';
import 'id_camera_screen.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  AddUserPageState createState() => AddUserPageState();
}

class AddUserPageState extends State<AddUserPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _groupIdController = TextEditingController();

  String? _facePhotoPath;
  String? _idFrontPhotoPath;
  String? _idBackPhotoPath;

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _addressController.dispose();
    _aadharController.dispose();
    _phoneController.dispose();
    _groupIdController.dispose();
    super.dispose();
  }

  Future<void> _navigateToCameraScreen(BuildContext context, String imageType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );
    if (result != null && result is String) {
      setState(() {
        if (imageType == 'face') {
          _facePhotoPath = result;
        }
      });
    }
  }

  Future<void> _navigateToIdCameraScreen(BuildContext context, String imageType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdCameraScreen(imageType: imageType),
      ),
    );
    if (result != null && result is String) {
      setState(() {
        if (imageType == 'id_front') {
          _idFrontPhotoPath = result;
        } else if (imageType == 'id_back') {
          _idBackPhotoPath = result;
        }
      });
    }
  }

  Future<void> _saveUser(BuildContext context) async {
    if (_nameController.text.isEmpty ||
        _facePhotoPath == null ||
        _idFrontPhotoPath == null ||
        _idBackPhotoPath == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields and capture all photos')),
        );
      }
      return;
    }

    Map<String, dynamic> user = {
      'name': _nameController.text,
      'father_name': _fatherNameController.text,
      'address': _addressController.text,
      'aadhar_no': _aadharController.text,
      'phone_no': _phoneController.text,
      'group_id': _groupIdController.text,
      'photo': _facePhotoPath,
      'id_front_photo': _idFrontPhotoPath,
      'id_back_photo': _idBackPhotoPath,
    };

    try {
      await DatabaseHelper().insertUser(user);

      if (mounted && context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving user: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving user')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _fatherNameController,
              decoration: const InputDecoration(labelText: 'Father\'s Name'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _aadharController,
              decoration: const InputDecoration(labelText: 'Aadhar No'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone No'),
            ),
            TextField(
              controller: _groupIdController,
              decoration: const InputDecoration(labelText: 'Group ID'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToCameraScreen(context, 'face'),
              child: const Text('Capture Face Photo'),
            ),
            if (_facePhotoPath != null) Image.file(File(_facePhotoPath!), height: 100),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToIdCameraScreen(context, 'id_front'),
              child: const Text('Capture ID Front Photo'),
            ),
            if (_idFrontPhotoPath != null) Image.file(File(_idFrontPhotoPath!), height: 100),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToIdCameraScreen(context, 'id_back'),
              child: const Text('Capture ID Back Photo'),
            ),
            if (_idBackPhotoPath != null) Image.file(File(_idBackPhotoPath!), height: 100),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveUser(context),
              child: const Text('Save User'),
            ),
          ],
        ),
      ),
    );
  }
}

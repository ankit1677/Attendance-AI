/*
import 'package:flutter/material.dart';
import 'dart:io';
import 'database_helper.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    List<Map<String, dynamic>> users = await DatabaseHelper().queryAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_users[index]['name']),
            leading: _users[index]['photo'] != null
                ? Image.file(File(_users[index]['photo']), height: 50)
                : null,
          );
        },
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'dart:io';
import 'database_helper.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    List<Map<String, dynamic>> users = await DatabaseHelper().queryAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
      });
    }
  }

  void _navigateToImageScreen(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageScreen(imagePath: imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (_users[index]['photo'] != null) {
                _navigateToImageScreen(_users[index]['photo']);
              }
            },
            child: ListTile(
              title: Text(_users[index]['name']),
              leading: _users[index]['photo'] != null
                  ? Image.file(File(_users[index]['photo']), height: 50)
                  : null,
            ),
          );
        },
      ),
    );
  }
}

class ImageScreen extends StatelessWidget {
  final String imagePath;

  const ImageScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Image'),
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}

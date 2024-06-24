import 'package:flutter/material.dart';
import 'dart:io';
import 'database_helper.dart';
import 'user_detail_screen.dart';

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

  void _navigateToUserDetail(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(user: user),
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
          return ListTile(
            title: Text(_users[index]['name']),
            leading: _users[index]['photo'] != null
                ? Image.file(File(_users[index]['photo']), height: 50)
                : null,
            onTap: () => _navigateToUserDetail(_users[index]),
          );
        },
      ),
    );
  }
}

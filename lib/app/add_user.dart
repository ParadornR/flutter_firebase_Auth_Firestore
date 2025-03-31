import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddUserScreen extends StatefulWidget {
  final CollectionReference<Map<String, dynamic>> users;
  const AddUserScreen({super.key, required this.users});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();

  Future<void> addUser() async {
    final String name = nameController.text;
    final String email = emailController.text;
    final int? age = int.tryParse(ageController.text);

    if (name.isNotEmpty && age != null && email.isNotEmpty) {
      nameController.clear();
      ageController.clear();
      emailController.clear();

      // เพิ่มข้อมูล
      await widget.users.add({'name': name, 'age': age, 'email': email});
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('เพิ่มผู้ใช้')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                maxLength: 20,
                controller: nameController,
                decoration: InputDecoration(labelText: 'ชื่อ'),
              ),
              TextField(
                maxLength: 2,
                controller: ageController,
                decoration: InputDecoration(labelText: 'อายุ'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                maxLength: 20,
                controller: emailController,
                decoration: InputDecoration(labelText: 'อีเมล'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: addUser, child: Text('เพิ่มผู้ใช้')),
            ],
          ),
        ),
      ),
    );
  }
}

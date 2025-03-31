import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final String uid;
  const Profile({super.key, required this.uid});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final users = FirebaseFirestore.instance.collection('users');
  TextEditingController? profileController = TextEditingController();
  TextEditingController? nameController = TextEditingController();
  TextEditingController? emailController = TextEditingController();
  bool isEditImage = false;
  bool isLoading = true;
  Future<void> updateUser() async {
    final String profile = profileController!.text;
    final String name = nameController!.text;
    final String email = emailController!.text;

    if (profile.isNotEmpty && name.isNotEmpty && email.isNotEmpty) {
      await users.doc(widget.uid).update({
        'profile_picture': profile,
        'name': name,
        'email': email,
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')));
    }
  }

  @override
  void initState() {
    fetchUserData();
    super.initState();
  }

  Future<void> fetchUserData() async {
    var snapshot = await users.doc(widget.uid).get();
    if (snapshot.exists) {
      var data = snapshot.data();
      profileController?.text = data?['profile_picture'];
      nameController?.text = data?['name'];
      emailController?.text = data?['email'];
      isLoading = !isLoading;
      setState(() {});
    } else {
      log("No data found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Profile'), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      if (isEditImage)
                        Column(
                          children: [
                            Text('Profile'),
                            TextField(
                              controller: profileController,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(),
                              ),
                              onSubmitted: (value) {
                                isEditImage = !isEditImage;
                                setState(() {});
                              },
                            ),
                          ],
                        )
                      else
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: MediaQuery.of(context).size.width * 0.15,
                              child: ClipOval(
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width,
                                  profileController!.text,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error, size: 25);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.325,
                              height: MediaQuery.of(context).size.width * 0.325,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      148,
                                      210,
                                      210,
                                      210,
                                    ),
                                    borderRadius: BorderRadius.circular(360),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      isEditImage = !isEditImage;
                                      log("$isEditImage");
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.photo),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          Text('Name'),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text('Email'),
                          TextField(
                            controller: emailController,
                            readOnly: true,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                updateUser();
                              },
                              child: Text("Update"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/app/login.dart';
import 'package:flutter_firebase/app/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final String uid;
  Home({super.key, required this.uid});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // collection users
  final users = FirebaseFirestore.instance.collection('users');

  // อ่านข้อมูล
  Stream<QuerySnapshot> getUsers() {
    return users.snapshots();
  }

  // ลบข้อมูล
  // Future<void> deleteUser(String docId) {
  //   return users.doc(docId).delete();
  // }

  Future<void> logOut(BuildContext context) async {
    // clear data and jump to login Screen
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogin');
    await prefs.remove('uid');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  List<dynamic> dataList = [];
  Future<void> getUser() async {
    try {
      final res = await Dio().get(
        "https://api.thecatapi.com/v1/images/search?limit=10",
      );
      dataList.addAll(res.data);
      setState(() {});
      log("dataList: $dataList");
      log("length: ${dataList.length}");
    } catch (e) {
      log("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Profile(uid: widget.uid)),
              );
            },
            icon: Icon(Icons.person),
          ),
          title: Text("Home"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                await logOut(context);
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: dataList.length,
          itemBuilder: (context, index) {
            log("dataList: ${dataList[index]['url']}");
            return CachedNetworkImage(
              imageUrl: dataList[index]['url'],
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            );

            // return Image.network(
            //   dataList[index]['url'],
            //   fit: BoxFit.cover,
            //   loadingBuilder: (context, child, loadingProgress) {
            //     if (loadingProgress == null) return child;
            //     return Center(child: CircularProgressIndicator());
            //   },
            //   errorBuilder: (context, error, stackTrace) {
            //     return Icon(Icons.error);
            //   },
            // );
          },
        ),
        // body: StreamBuilder<QuerySnapshot>(
        //   stream: getUsers(),
        //   builder: (context, snapshot) {
        //     if (!snapshot.hasData) {
        //       return Center(child: CircularProgressIndicator());
        //     }
        //     final docs = snapshot.data!.docs;
        //     return ListView.builder(
        //       itemCount: docs.length,
        //       itemBuilder: (context, index) {
        //         final data = docs[index].data() as Map<String, dynamic>;
        //         return ListTile(
        //           leading: CircleAvatar(child: Text(data['name'])),
        //           title: Text(data['email']),
        //           subtitle: Text("${data['uid']}"),
        //         );
        //       },
        //     );
        //   },
        // ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            getUser();
            // final SharedPreferences prefs =
            //     await SharedPreferences.getInstance();
            // log('${prefs.getBool('isLogin')}');
            // log('${prefs.getString('uid')}');

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (_) => AddUserScreen(users: users)),
            // );
          },
        ),
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_firebase/app/home.dart';
import 'package:flutter_firebase/app/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
  }

  String uid = '';
  Future<bool?> checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    log('isLogin: ${prefs.getBool('isLogin')}');
    log('uid: ${prefs.getString('uid')}');
    if (prefs.getBool('isLogin') == true) {
      uid = prefs.getString('uid')!;
    }
    return prefs.getBool('isLogin');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: checkLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.data == null || snapshot.data == false) {
            return LoginScreen();
          } else {
            return Home(uid: uid);
          }
        },
      ),
    );
  }
}

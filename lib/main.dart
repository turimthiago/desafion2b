import 'package:blogup_app/auth/auth.dart';
import 'package:blogup_app/auth/auth_firebase_impl.dart';
import 'package:blogup_app/pages/splash_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BlogUp App",
      theme:
          ThemeData(primaryColor: Colors.blue, accentColor: Colors.blueAccent),
      home: SplashPage(),
    );
  }
}

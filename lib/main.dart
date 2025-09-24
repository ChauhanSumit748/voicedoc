import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screen/LoginScreen.dart';
import 'Screen/VoiceDocHomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDI9U3lfRpFuWK66wRyh6_GKbBA-tcCJeE',
      appId: '1:657344197924:android:1fbe660e374a7a78362fb1',
      messagingSenderId: '657344197924',
      projectId: 'candid-cf9fc',
      storageBucket: 'candid-cf9fc.appspot.com',
    ),
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLoggedIn ? VoiceDocHomeScreen() : LoginScreen(),
    );
  }
}

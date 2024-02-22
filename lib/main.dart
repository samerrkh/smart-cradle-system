import 'package:flutter/material.dart';
import 'package:smart_cradle_system/login.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peaceful Cradle',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 231, 246, 254),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Color.fromARGB(255, 25, 16, 67),
          selectedLabelStyle: TextStyle(fontSize: 16),
          unselectedLabelStyle: TextStyle(fontSize: 14),
          elevation: 0, // Optionally set the elevation to suit your design
        ),
      ),
      home: const Login(),
    );
  }
}

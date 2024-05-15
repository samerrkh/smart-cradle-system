import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_cradle_system/firebase_options.dart';
import 'package:smart_cradle_system/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

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
          backgroundColor: Color.fromARGB(255, 220, 231, 244),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Color.fromARGB(255, 25, 16, 67),
          selectedLabelStyle: TextStyle(fontSize: 16),
          unselectedLabelStyle: TextStyle(fontSize: 14),
          elevation: 0,
        ),
      ),
      home:const Login(),
    );
  }
}

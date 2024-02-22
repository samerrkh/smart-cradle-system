import 'package:flutter/material.dart';
import 'package:smart_cradle_system/login.dart';
import 'package:smart_cradle_system/widgets/appbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String sensorId = "";

  void _logout(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titleText: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text(
              'Sensor ID',
              style: TextStyle(fontSize: 20), // Increase text size
            ),
            subtitle: TextField(
              decoration: const InputDecoration(
                hintText: "Enter your sensor's ID",
              ),
              onChanged: (String value) {
                setState(() {
                  sensorId = value;
                });
              },
            ),
            leading: const Icon(
              Icons.sensor_door,
              size: 30, // Increase icon size
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text(
              'Logout',
              style: TextStyle(fontSize: 20), // Increase text size
            ),
            leading: const Icon(
              Icons.exit_to_app,
              size: 30, // Increase icon size
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

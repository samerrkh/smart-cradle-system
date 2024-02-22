// temp_humidity_screen.dart
import 'package:flutter/material.dart';

class TempHumidityScreen extends StatelessWidget {
  const TempHumidityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature & Humidity'),
      ),
      body: const Center(
        child: Text('Current Temperature and Humidity levels'),
      ),
    );
  }
}

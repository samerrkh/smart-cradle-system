// noise_detection_screen.dart
import 'package:flutter/material.dart';

class NoiseDetectionScreen extends StatelessWidget {
  const NoiseDetectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noise Detection'),
      ),
      body: const Center(
        child: Text('Noise levels in the baby’s room'),
      ),
    );
  }
}

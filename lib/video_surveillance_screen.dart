// video_surveillance_screen.dart
import 'package:flutter/material.dart';

class VideoSurveillanceScreen extends StatelessWidget {
  const VideoSurveillanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Video Surveillance'),
      ),
      body: const Center(
        child: Text('Live feed from baby’s cradle'),
      ),
      
    );
  }
}

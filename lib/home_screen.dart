import 'package:flutter/material.dart';
import 'package:smart_cradle_system/widgets/appbar.dart';
import 'video_surveillance_screen.dart';
import 'temp_humidity_screen.dart';
import 'noise_detection_screen.dart';
import 'notifications_screen.dart';
import 'play_lullaby_songs.dart';  // Ensure this import is correct

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> _pages = [
    const VideoSurveillanceScreen(),
    const TempHumidityScreen(),
    const NoiseDetectionScreen(),
    const NotificationsScreen(),
    const PlayLullabySongs(),  
  ];

  final List<String> _titles = [
    'Baby Monitor',
    'Temperature & Humidity',
    'Noise Detection',
    'Notifications',
    'Lullaby Songs',
  ];

  final List<IconData> _icons = [
    Icons.videocam,
    Icons.thermostat,
    Icons.hearing,
    Icons.notifications,
    Icons.music_note,
  ];

  final List<String> animatedImages = [
    'assets/images/monitor.jpg',
    'assets/images/humidity.jpg',
    'assets/images/noise.jpg',
    'assets/images/notification.jpg',
    'assets/images/style-music.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titleText: 'Peaceful Cradle'),
      body: ListView.builder(
        itemCount: _pages.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          return _buildAnimatedGridButton(
            context,
            _titles[index],
            _icons[index],
            _pages[index],
            index,
          );
        },
      ),
    );
  }

  Widget _buildAnimatedGridButton(BuildContext context, String title, IconData icon, Widget destinationScreen, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AnimatedOpacity(
        opacity: 0.9,
        duration: Duration(milliseconds: 500 + (index * 100)),  // Staggered animation effect
        child: Container(
          height: 180,  // Increased height for the container
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9.0),
            color: Theme.of(context).colorScheme.surface,  // Fallback color
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destinationScreen),
              );
            },
            child: Stack(
              fit: StackFit.expand,  // Make the stack fill the container
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9.0),
                  child: Image.asset(
                    animatedImages[index],
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),  // Semi-transparent background for the label
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(9.0),
                        bottomRight: Radius.circular(9.0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 30.0, color: Colors.white),  // Increased icon size
                        const SizedBox(width: 8.0),  // Space between icon and text
                        Expanded(
                          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16.0)),  // Increased text size
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

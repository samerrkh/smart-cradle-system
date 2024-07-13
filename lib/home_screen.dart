import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_cradle_system/widgets/appbar.dart';
import 'monitoring_options_screen.dart';
import 'temp_humidity_screen.dart';
import 'cry_detection_screen.dart';
import 'notifications_screen.dart';
import 'play_lullaby_songs.dart';
import 'gas_sensor_provider.dart';
import 'main.dart'; // Import the main.dart to access MyAppState

class HomeScreen extends StatefulWidget {
  final int initialNotificationCount;

  const HomeScreen({Key? key, required this.initialNotificationCount}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final List<Widget> _pages = [
    const MonitoringOptionsScreen(),
    const TempHumidityScreen(),
    const CryDetectionScreen(),
    const NotificationsScreen(),
    const PlayLullabySongs(),
  ];

  final List<String> _titles = [
    'Baby Monitor',
    'Temperature & Humidity',
    'Cry Detection',
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
    final gasSensorProvider = Provider.of<GasSensorProvider>(context);

    // Listen for changes in gas detection status and handle notifications
    if (gasSensorProvider.gasDetectedPreviously) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleGasDetection(context);
      });
    }

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
            gasSensorProvider.notificationCount,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _handleGasDetection(context);
        },
        child: const Icon(Icons.notification_important),
      ),
    );
  }

  void _handleGasDetection(BuildContext context) {
    final myAppState = navigatorKey.currentState?.context.findAncestorStateOfType<MyAppState>();

    if (myAppState != null) {
      debugPrint('Handling gas detection in HomeScreen.');
      myAppState.playNotificationSound();
      myAppState.sendNotification("Danger Alert", "Gas detected! Please check the room immediately.");
      myAppState.showLocalNotification();
      myAppState.showGasDetectedDialog(context);
    } else {
      debugPrint('MyAppState not found.');
    }
  }

  Widget _buildAnimatedGridButton(BuildContext context, String title, IconData icon, Widget destinationScreen, int index, int notificationCount) {
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
            onTap: () async {
              if (title == 'Notifications') {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => destinationScreen),
                );
                // ignore: use_build_context_synchronously
                Provider.of<GasSensorProvider>(context, listen: false).resetNotificationCount();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => destinationScreen),
                );
              }
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
                        if (title == 'Notifications' && notificationCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            child: Text(
                              '$notificationCount',
                              style: const TextStyle(color: Colors.white, fontSize: 16.0),
                            ),
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

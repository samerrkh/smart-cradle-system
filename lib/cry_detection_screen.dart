import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_cradle_system/widgets/appbar_witharrow.dart';

class CryDetectionScreen extends StatefulWidget {
  const CryDetectionScreen({Key? key}) : super(key: key);

  @override
  CryDetectionScreenState createState() => CryDetectionScreenState();
}

class CryDetectionScreenState extends State<CryDetectionScreen>
    with SingleTickerProviderStateMixin {
  Stream<DatabaseEvent>? _cryDetectionStream;
  String? serialNumber;
  bool isLoading = true;
  bool isCrying = false;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _sizeAnimation;
  late FlutterLocalNotificationsPlugin _localNotifications;

  @override
  void initState() {
    super.initState();
    fetchInitialData();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(114, 0, 0, 0),
      end: const Color.fromARGB(114, 0, 0, 0),
    ).animate(_controller);

    _sizeAnimation = Tween<double>(begin: 100.0, end: 200.0).animate(_controller);

    _localNotifications = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    _localNotifications.initialize(initializationSettings);
  }

  void fetchInitialData() async {
    try {
      // Fetching serial number from Firestore
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await FirebaseFirestore.instance
              .collection('sensors')
              .doc('all-boards')
              .get();
      var data = docSnapshot.data();
      if (data != null &&
          data.containsKey('raspberry_pis') &&
          data['raspberry_pis'].isNotEmpty) {
        serialNumber = data['raspberry_pis']
            [0]; // Assuming it's a list and we need the first item
        if (serialNumber != null) {
          // Using the serial number to set up Realtime Database stream
          _cryDetectionStream = FirebaseDatabase.instance
              .ref('sensor_data/$serialNumber/cry_detection/detected')
              .onValue;
        }
        setState(() {
          isLoading = false;
        });
      } else {
        debugPrint('Serial number not found in Firestore document.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch serial number from Firestore: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showNotification() {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'cry_detection_channel',
      'Cry Detection Notifications',
      channelDescription: 'Notifications for baby cry detection',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    _localNotifications.show(
      0,
      'Baby Cry Detection',
      'Your baby is crying!',
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titleText: 'Cry Detection'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cryDetectionStream == null
              ? const Center(child: Text('Failed to load data'))
              : StreamBuilder<DatabaseEvent>(
                  stream: _cryDetectionStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.data!.snapshot.value == null) {
                      return const Center(child: Text('No data available'));
                    }

                    var data = snapshot.data!.snapshot.value;
                    if (data is! bool) {
                      return const Center(
                          child: Text('Data format is not correct'));
                    }

                    bool isCrying = data;
                    if (isCrying) {
                      _controller.forward();
                      _showNotification();
                    } else {
                      _controller.reverse();
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            width: _sizeAnimation.value,
                            height: _sizeAnimation.value,
                            decoration: BoxDecoration(
                              color: _colorAnimation.value,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                isCrying ? Icons.error : Icons.check,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isCrying
                                ? 'The baby is crying!'
                                : 'The baby is okay, not crying.',
                            style: GoogleFonts.robotoCondensed(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: isCrying ? Colors.black38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

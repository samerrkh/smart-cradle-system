import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'gas_sensor_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Stream<DatabaseEvent>? _gasSensorStream;
  String? serialNumber;
  bool isLoading = true;
  bool gasDetectedPreviously = false;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  void fetchInitialData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await FirebaseFirestore.instance
              .collection('sensors')
              .doc('all-boards')
              .get();
      var data = docSnapshot.data();
      if (data != null &&
          data.containsKey('raspberry_pis') &&
          data['raspberry_pis'].isNotEmpty) {
        serialNumber = data['raspberry_pis'][0];
        if (serialNumber != null) {
          _gasSensorStream = FirebaseDatabase.instance
              .ref('sensor_data/$serialNumber/gas-sensor')
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

  void sendNotification(String title, String body) async {
    try {
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendDangerAlert');
      final results = await callable.call(<String, dynamic>{
        'title': title,
        'body': body,
      });
      if (results.data['success']) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  void playNotificationSound() {
    FlutterRingtonePlayer.play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      looping: false,
      volume: 0.4,
      asAlarm: false,
    );
  }

  void showGasDetectedDialog(BuildContext context) {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Danger Alert'),
            content: const Text('Gas detected! Please check the room immediately.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gasSensorProvider = Provider.of<GasSensorProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          badges.Badge(
            badgeContent: gasSensorProvider.notificationCount > 0 ? Text('${gasSensorProvider.notificationCount}', style: const TextStyle(color: Colors.white)) : null,
            child: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gasSensorStream == null
              ? const Center(child: Text('Failed to load gas sensor data'))
              : StreamBuilder<DatabaseEvent>(
                  stream: _gasSensorStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                      return const Center(child: Text('No gas sensor data available'));
                    }

                    var data = snapshot.data!.snapshot.value;
                    if (data is! List) {
                      return const Center(child: Text('Gas sensor data format is not correct'));
                    }

                    List<Map<String, dynamic>> gasData = List<Map<String, dynamic>>.from(
                      (data).map((item) => Map<String, dynamic>.from(item))
                    );

                    if (gasData.isNotEmpty) {
                      var latestGasData = gasData.last;
                      bool gasDetected = latestGasData['gas_detected'] == "Gas detected!!";
                      if (gasDetected && !gasSensorProvider.gasDetectedPreviously) {
                        gasSensorProvider.playNotificationSound();
                        gasSensorProvider.showGasDetectedDialog(context);
                        gasSensorProvider.sendNotification("Danger Alert", "Gas detected! Please check the room immediately.");
                        gasSensorProvider.gasDetectedPreviously = true;
                        gasSensorProvider.notificationCount++;
                      } else if (!gasDetected) {
                        gasSensorProvider.gasDetectedPreviously = false;
                      }

                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: gasDetected ? 1 : 0,
                              backgroundColor: Colors.green,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              gasDetected ? 'Danger Alert: Gas detected!' : 'No gas detected',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: gasDetected ? Colors.red : Colors.green,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Latest Update: ${latestGasData['timestamp']}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(child: Text('No gas sensor data available'));
                    }
                  },
                ),
    );
  }
}

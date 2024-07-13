// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'main.dart';

// class GasSensorService {
//   Stream<DatabaseEvent>? _gasSensorStream;
//   String? serialNumber;
//   bool gasDetectedPreviously = false;

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   GasSensorService() {
//     fetchInitialData();
//   }

//   void fetchInitialData() async {
//     try {
//       DocumentSnapshot<Map<String, dynamic>> docSnapshot =
//           await FirebaseFirestore.instance
//               .collection('sensors')
//               .doc('all-boards')
//               .get();
//       var data = docSnapshot.data();
//       if (data != null &&
//           data.containsKey('raspberry_pis') &&
//           data['raspberry_pis'].isNotEmpty) {
//         serialNumber = data['raspberry_pis'][0];
//         if (serialNumber != null) {
//           _gasSensorStream = FirebaseDatabase.instance
//               .ref('sensor_data/$serialNumber/gas-sensor')
//               .onValue;
//           _gasSensorStream!.listen((DatabaseEvent event) {
//             if (event.snapshot.value != null) {
//               var sensorData = Map<String, dynamic>.from(event.snapshot.value as Map);
//               bool gasDetected = sensorData['gas_detected'] == "Gas detected!!";
//               if (gasDetected && !gasDetectedPreviously) {
//                 playNotificationSound();
//                 sendNotification("Danger Alert", "Gas detected! Please check the room immediately.");
//                 showGasDetectedDialog(navigatorKey.currentContext!);
//                 gasDetectedPreviously = true;
//               } else if (!gasDetected) {
//                 gasDetectedPreviously = false;
//               }
//             }
//           });
//         }
//       } else {
//         debugPrint('Serial number not found in Firestore document.');
//       }
//     } catch (e) {
//       debugPrint('Failed to fetch serial number from Firestore: $e');
//     }
//   }

//   void sendNotification(String title, String body) async {
//     try {
//       HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendDangerAlert');
//       final results = await callable.call(<String, dynamic>{
//         'title': title,
//         'body': body,
//       });
//       if (results.data['success']) {
//         print('Notification sent successfully');
//       } else {
//         print('Failed to send notification');
//       }
//     } catch (e) {
//       print('Error sending notification: $e');
//     }
//   }

//   void playNotificationSound() {
//     FlutterRingtonePlayer.play(
//       android: AndroidSounds.notification,
//       ios: IosSounds.glass,
//       looping: false,
//       volume: 0.4,
//       asAlarm: false,
//     );
//   }

//   void showGasDetectedDialog(BuildContext context) {
//     if (!isCurrentRouteNotificationScreen()) {
//       flutterLocalNotificationsPlugin.show(
//         0,
//         "Danger Alert",
//         "Gas detected! Please check the room immediately.",
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'high_importance_channel',
//             'High Importance Notifications',
//             importance: Importance.high,
//             priority: Priority.high,
//             playSound: true,
//           ),
//         ),
//       );
//     } else {
//       Future.delayed(Duration.zero, () {
//         if (context != null && context.mounted) {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Danger Alert'),
//               content: const Text('Gas detected! Please check the room immediately.'),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: const Text('OK'),
//                 ),
//               ],
//             ),
//           );
//         }
//       });
//     }
//   }

//   bool isCurrentRouteNotificationScreen() {
//     String? currentRoute = ModalRoute.of(navigatorKey.currentContext!)?.settings.name;
//     return currentRoute == "/notifications";
//   }
// }

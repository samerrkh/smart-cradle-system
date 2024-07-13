// import 'package:flutter/material.dart';
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
// import 'package:noise_meter/noise_meter.dart';
// import 'dart:async';

// class CryDetectorProvider with ChangeNotifier {
//   bool cryDetectedPreviously = false;
//   int notificationCount = 0;
//   NoiseMeter? _noiseMeter;
//   StreamSubscription<NoiseReading>? _noiseSubscription;
//   void Function()? showCryDetectedDialogCallback;

//   CryDetectorProvider() {
//     _noiseMeter = NoiseMeter(onError);
//     startListening();
//   }

//   void setDialogCallback(void Function()? callback) {
//     showCryDetectedDialogCallback = callback;
//   }

//   void startListening() {
//     try {
//       _noiseSubscription = _noiseMeter?.onNoiseMeasured.listen((NoiseReading noiseReading) {
//         if (noiseReading.meanDecibel > 70) { // Adjust the decibel level as needed
//           if (!cryDetectedPreviously) {
//             playNotificationSound();
//             if (showCryDetectedDialogCallback != null) {
//               showCryDetectedDialogCallback!();
//             }
//             sendNotification("Cry Alert", "Baby is crying! Please check immediately.");
//             cryDetectedPreviously = true;
//             notificationCount++;
//             notifyListeners();
//           }
//         } else {
//           cryDetectedPreviously = false;
//           notifyListeners();
//         }
//       }, onError: onError);
//     } catch (e) {
//       onError(e);
//     }
//   }

//   void stopListening() {
//     _noiseSubscription?.cancel();
//   }

//   void onError(Object error) {
//     debugPrint(error.toString());
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

//   @override
//   void dispose() {
//     stopListening();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:smart_cradle_system/widgets/appbar_witharrow.dart';

class TempHumidityScreen extends StatefulWidget {
  const TempHumidityScreen({Key? key}) : super(key: key);

  @override
  TempHumidityScreenState createState() => TempHumidityScreenState();
}

class TempHumidityScreenState extends State<TempHumidityScreen> {
  Stream<DatabaseEvent>? _tempHumidityStream;
  String? serialNumber;
  bool isLoading = true;
  double temperature = 0.0;
  double humidity = 0.0;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
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
          _tempHumidityStream = FirebaseDatabase.instance
              .ref('sensor_data/$serialNumber/tempAndHumidity')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titleText: "Temperature & Humidity"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tempHumidityStream == null
              ? const Center(child: Text('Failed to load data'))
              : StreamBuilder<DatabaseEvent>(
                  stream: _tempHumidityStream,
                  builder: (context, snapshot) {
                    // Error handling and data extraction remain the same

                    if (!snapshot.hasData ||
                        snapshot.data!.snapshot.value == null) {
                      return const Center(child: Text('No data available'));
                    }

                    var data = snapshot.data!.snapshot.value;
                    if (data is! Map) {
                      return const Center(
                          child: Text('Data format is not correct'));
                    }

                    Map<String, dynamic> mapData =
                        Map<String, dynamic>.from(data);
                    temperature =
                        (mapData['temperature'] as num?)?.toDouble() ?? 0.0;
                    humidity = (mapData['humidity'] as num?)?.toDouble() ?? 0.0;
                    String lastUpdate = mapData['timestamp'] ?? 'Not available';

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: SfRadialGauge(
                              axes: <RadialAxis>[
                                RadialAxis(
                                    minimum: 0,
                                    maximum: 50,
                                    axisLineStyle: AxisLineStyle(
                                      thickness: 20,
                                      color: Colors.blue[100],
                                      thicknessUnit: GaugeSizeUnit.logicalPixel,
                                    ),
                                    axisLabelStyle: const GaugeTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                    ),
                                    ranges: <GaugeRange>[
                                      GaugeRange(
                                          startValue: 0,
                                          endValue: 50,
                                          color: Colors.red[300],
                                          startWidth: 5,
                                          endWidth: 10,
                                          ),
                                    ],
                                    pointers: <GaugePointer>[
                                      NeedlePointer(value: temperature)
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                          widget: Text(
                                              'Temperature: ${temperature.toStringAsFixed(2)}°C',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red)),
                                          angle: 90,
                                          positionFactor: 0.5)
                                    ])
                              ],
                            ),
                          ),
                          Expanded(
                            child: SfRadialGauge(
                              axes: <RadialAxis>[
                                RadialAxis(
                                    minimum: 0,
                                    maximum: 100,
                                    axisLineStyle: AxisLineStyle(
                                      thickness: 20,
                                      color: Colors.red[100],
                                      thicknessUnit: GaugeSizeUnit.logicalPixel,
                                    ),
                                    axisLabelStyle: const GaugeTextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black
                                    ),
                                    ranges: <GaugeRange>[
                                      GaugeRange(
                                          startValue: 0,
                                          endValue: 100,
                                          color: Colors.blue[300],
                                          startWidth: 5,
                                          endWidth: 10,),
                                    ],
                                    pointers: <GaugePointer>[
                                      NeedlePointer(value: humidity)
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                          widget: Text(
                                              'Humidity: ${humidity.toStringAsFixed(2)}%',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue)),
                                          angle: 90,
                                          positionFactor: 0.5)
                                    ])
                              ],
                            ),
                          ),
                          Text(
                          ' $lastUpdate',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,height: 2),
                          
                        ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

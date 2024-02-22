// monitoring_options_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_cradle_system/widgets/appbar.dart';

class MonitoringOptionsScreen extends StatelessWidget {
  const MonitoringOptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(titleText: 'Monitoring'),
      body: Center(
        child: Text('Monitoring options and features'),
      ),
    );
  }
}

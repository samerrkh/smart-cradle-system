import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_cradle_system/login.dart';
import 'package:smart_cradle_system/widgets/appbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController? _piSerialController;

  @override
  void initState() {
    super.initState();
    _piSerialController = TextEditingController();
    _fetchPiSerial();
  }

  @override
  void dispose() {
    _piSerialController?.dispose();
    super.dispose();
  }

  Future<void> _fetchPiSerial() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      if (docSnapshot.exists && docSnapshot.data()!.containsKey('piSerial')) {
        setState(() {
          _piSerialController!.text = docSnapshot.data()!['piSerial'];
        });
      }
    }
  }

  Future<void> _confirmDeletion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to delete the Pi Serial?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _deletePiSerial();
    }
  }

  Future<void> _deletePiSerial() async {
    _piSerialController?.clear();
    await _updateOrAddPiSerial(); // Update Firestore
  }

  Future<void> _updateOrAddPiSerial() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final piSerial = _piSerialController!.text.trim();
      if (await _piSerialExists(piSerial) || piSerial.isEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'piSerial': piSerial.isEmpty ? FieldValue.delete() : piSerial,
        });
        
        if (piSerial.isNotEmpty) {
          _showDialog1('The Pi Serial updated successfully.');
        }
      } else {
        _showDialog('The Pi Serial is not correct. Please try again.');
        _piSerialController?.clear();
      }
    }
  }

  Future<bool> _piSerialExists(String piSerial) async {
    final docSnapshot = await FirebaseFirestore.instance.collection('sensors').doc('all-boards').get();
    if (docSnapshot.exists && docSnapshot.data()!.containsKey('raspberry_pis')) {
      List<dynamic> piSerials = docSnapshot.get('raspberry_pis');
      return piSerials.contains(piSerial);
    }
    return false;
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()));
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showDialog1(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Successful"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context). pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titleText: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text(
              'Pi Serial',
              style: TextStyle(fontSize: 20),
            ),
            subtitle: TextField(
              controller: _piSerialController,
              decoration: InputDecoration(
                hintText: "Enter your Pi's serial number",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _confirmDeletion, // Trigger confirmation dialog
                ),
              ),
              onSubmitted: (value) => _updateOrAddPiSerial(),
            ),
            leading: const Icon(
              Icons.computer,
              size: 30,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _updateOrAddPiSerial(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              "Update Pi Serial",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text(
              'Logout',
              style: TextStyle(fontSize: 20),
            ),
            leading: const Icon(
              Icons.exit_to_app,
              size: 30,
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

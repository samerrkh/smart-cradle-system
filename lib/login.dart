import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'package:smart_cradle_system/widgets/appbar.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController sensorIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titleText: "Sensor's Registration"),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // Logo
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Center(
              child: Image.asset(
                'assets/images/cradle_logo.png',
                height: 200,
                width: 350,
              ),
            ),
          ),
          // Sensor ID TextField
          TextField(
            controller: sensorIdController,
            keyboardType: TextInputType.number, // Ensures keyboard is numeric
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter
                  .digitsOnly, // Allows only digits to be entered
            ],
            decoration: InputDecoration(
              labelText: "Sensor ID",
              hintText: "Enter your sensor's ID",
              labelStyle: const TextStyle(
                fontSize: 20, 
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),

          const SizedBox(height: 32.0),
          // Registration Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 255, 253, 253),
              backgroundColor: const Color.fromARGB(255, 66, 78, 245),
              shape: RoundedRectangleBorder(
                // Button shape
                borderRadius: BorderRadius.circular(18.0),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: 15.0, horizontal: 40.0), // Button padding
            ),
            onPressed: () {
              if (sensorIdController.text.isNotEmpty) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainScreen()));
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Attention!"),
                    content: const Text("Please enter the sensor ID."),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Okay"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text(
              "Register Sensor",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

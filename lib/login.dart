import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'main_screen.dart';
import 'package:smart_cradle_system/widgets/appbar.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  String selectedCountryCode = '+972'; // Default to Israel's country code

  final List<String> countryCodes = [
    '+972', // Israel
    '+970', // Palestine
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titleText: "Phone Authentication"),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
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
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedCountryCode,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCountryCode = newValue!;
                    });
                  },
                  items: countryCodes
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    hintText: "Enter your phone number",
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: _verificationId == null ? _verifyPhoneNumber : null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Verify Phone",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
          ),
          if (_verificationId != null)
            Column(
              children: [
                const SizedBox(height: 35.0),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "OTP",
                    hintText: "Enter OTP",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _signInWithPhoneNumber,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Sign In",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _verifyPhoneNumber() async {
    final fullPhoneNumber = "$selectedCountryCode${phoneController.text}";
    await _auth.verifyPhoneNumber(
      phoneNumber: fullPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        _showDialog(e.message ?? 'An error occurred');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  Future<void> _signInWithCredential(AuthCredential credential) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final bool isNewUser =
          userCredential.additionalUserInfo?.isNewUser ?? false;
      final User? user = userCredential.user;

      if (user != null) {
        final DocumentReference userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final DocumentSnapshot userSnapshot = await userDoc.get();

        if (!userSnapshot.exists || isNewUser) {
          await userDoc.set({
            'phone': user.phoneNumber,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        // Cast the data to Map<String, dynamic> to use the [] operator safely
        final data = userSnapshot.data() as Map<String, dynamic>?;

        // Check if the piSerial key exists and is not null before navigating
        final String? piSerial = data?['piSerial'];
        if (piSerial == null) {
          _promptForPiSerial();
        } else {
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      }
    } catch (e) {
      _showDialog('An error occurred during sign in');
    }
  }

  Future<void> _promptForPiSerial() async {
    TextEditingController piSerialController = TextEditingController();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Enter Raspberry Pi Serial'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: piSerialController,
                decoration:
                    const InputDecoration(hintText: 'Enter or scan piSerial'),
              ),
              ElevatedButton(
                onPressed: () => _scanQRCode(piSerialController),
                child: const Text('Scan QR Code'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                String piSerial = piSerialController.text.trim();
                if (piSerial.isNotEmpty) {
                  await _savePiSerialToFirebase(piSerial);
                  Navigator.pushReplacement(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                } else {
                  _showDialog(
                      "The Raspberry Pi serial is not correct. Please try again.");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePiSerialToFirebase(String piSerial) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'piSerial': piSerial,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _scanQRCode(TextEditingController piSerialController) async {
    // Add your QR code scanning logic here
  }

  void _signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpController.text,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      _showDialog('Failed to sign in with phone number');
    }
  }

  void _showDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
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
  }
}

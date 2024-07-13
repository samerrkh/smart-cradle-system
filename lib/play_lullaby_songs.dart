import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:smart_cradle_system/widgets/appbar_witharrow.dart';

class PlayLullabySongs extends StatefulWidget {
  const PlayLullabySongs({Key? key}) : super(key: key);

  @override
  PlayLullabySongsState createState() => PlayLullabySongsState();
}

class PlayLullabySongsState extends State<PlayLullabySongs> {
  final List<Map<String, String>> songs = [
    {"name": "Twinkle Twinkle Little Star", "path": "twinkle_twinkle"},
    {"name": "Rock-a-bye Baby", "path": "rock_a_bye_baby"},
    {"name": "Brahms' Lullaby", "path": "brahms_lullaby"},
  ];

  String? currentSong;
  double volume = 0.5;
  bool isPlaying = false;
  bool isLooping = false;
  Timer? _timer;
  final String raspberryPiUrl = 'http://192.168.1.106:5000';

  @override
  void initState() {
    super.initState();
    _startStatusTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStatusTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchStatus();
    });
  }

  Future<void> _fetchStatus() async {
    final response = await http.get(Uri.parse('$raspberryPiUrl/status'));
    if (response.statusCode == 200) {
      final status = jsonDecode(response.body)['status'];
      final stateMatch = RegExp(r'\( state (\w+) \)').firstMatch(status);
      if (stateMatch != null) {
        String state = stateMatch.group(1)!;
        setState(() {
          isPlaying = state == 'playing';
          if (state == 'stopped') {
            currentSong = null;
            isPlaying = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        titleText: 'Play Lullaby Songs',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: const Color.fromARGB(255, 242, 247, 254),
                    child: ListTile(
                      title: Text(
                        songs[index]["name"]!,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () => selectSong(songs[index]["path"]!),
                      leading: const Icon(Icons.music_note, color: Colors.blue),
                      trailing: currentSong == songs[index]["path"]
                          ? const Icon(Icons.play_arrow, color: Colors.blue)
                          : null,
                    ),
                  );
                },
              ),
            ),
            if (currentSong != null) _nowPlaying(),
            _volumeControl(),
            _loopControl(),
          ],
        ),
      ),
    );
  }

  Widget _nowPlaying() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 226, 233, 243),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 8,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$currentSong',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 40,
                color: Colors.blue,
                onPressed: togglePlay,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _volumeControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        children: [
          const Icon(Icons.volume_up, color: Colors.blue),
          Expanded(
            child: Slider(
              value: volume,
              min: 0,
              max: 1,
              divisions: 10,
              activeColor: Colors.blue,
              label: 'Volume: ${(volume * 100).toStringAsFixed(0)}%',
              onChanged: (newVolume) {
                setState(() {
                  volume = newVolume;
                });
                adjustVolume(volume);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _loopControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.loop, color: Colors.blue),
          Switch(
            value: isLooping,
            activeColor: Colors.blue,
            onChanged: (newValue) {
              setState(() {
                isLooping = newValue;
              });
              setLoop(newValue);
            },
          ),
        ],
      ),
    );
  }

  void selectSong(String song) async {
    setState(() {
      currentSong = song;
      isPlaying = true;
    });
    final response = await http.post(
      Uri.parse('$raspberryPiUrl/play'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'song': song,
        'volume': volume,
        'loop': isLooping,
      }),
    );
    if (response.statusCode != 200) {
      setState(() {
        currentSong = null;
        isPlaying = false;
      });
    }
  }

  void togglePlay() async {
    final response = await http.post(
      Uri.parse('$raspberryPiUrl/toggle'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        isPlaying = !isPlaying;
      });
    }
  }

  void adjustVolume(double volume) async {
    await http.post(
      Uri.parse('$raspberryPiUrl/volume'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'volume': volume,
      }),
    );
  }

  void setLoop(bool loop) async {
    await http.post(
      Uri.parse('$raspberryPiUrl/loop'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'loop': loop,
      }),
    );
  }
}

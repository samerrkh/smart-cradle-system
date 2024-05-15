import 'package:flutter/material.dart';

class PlayLullabySongs extends StatefulWidget {
  const PlayLullabySongs({Key? key}) : super(key: key);

  @override
  PlayLullabySongsState createState() => PlayLullabySongsState();
}

class PlayLullabySongsState extends State<PlayLullabySongs> {
  final List<String> songs = [
    "Twinkle Twinkle Little Star",
    "Rock-a-bye Baby",
    "Brahms' Lullaby",
    // Add more songs as needed
  ];

  String? currentSong;
  double volume = 0.5; // Default volume
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Lullaby Songs'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(songs[index]),
                  onTap: () => selectSong(songs[index]),
                  leading: const Icon(Icons.music_note),
                  trailing: currentSong == songs[index] ? const Icon(Icons.play_arrow) : null,
                );
              },
            ),
          ),
          if (currentSong != null) _nowPlaying(),
          _volumeControl(),
        ],
      ),
    );
  }

  Widget _nowPlaying() {
    return Column(
      children: [
        Text('Now Playing: $currentSong'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: togglePlay,
            ),
          ],
        ),
      ],
    );
  }

  Widget _volumeControl() {
    return Slider(
      value: volume,
      min: 0,
      max: 1,
      divisions: 10,
      label: 'Volume: ${(volume * 100).toStringAsFixed(0)}%',
      onChanged: (newVolume) {
        setState(() {
          volume = newVolume;
        });
        adjustVolume(volume);
      },
    );
  }

  void selectSong(String song) {
    setState(() {
      currentSong = song;
      isPlaying = true;
    });
    // Add code to send command to Raspberry Pi to play selected song
  }

  void togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
    });
    // Add code to send play/pause command to Raspberry Pi
  }

  void adjustVolume(double volume) {
    // Add code to send volume adjustment command to Raspberry Pi
  }
}

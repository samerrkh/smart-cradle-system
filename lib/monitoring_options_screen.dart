import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_cradle_system/widgets/appbar_witharrow.dart';

class MonitoringOptionsScreen extends StatefulWidget {
  const MonitoringOptionsScreen({Key? key}) : super(key: key);

  @override
  MonitoringOptionsScreenState createState() => MonitoringOptionsScreenState();
}

class MonitoringOptionsScreenState extends State<MonitoringOptionsScreen> {
  late VlcPlayerController _vlcPlayerController;
  String _connectionTestMessage = "Testing connection...";
  bool _isLoading = true;
  bool _isInitialized = false;
  bool _isMicActive = false;
  late WebSocketChannel _audioOutChannel;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

  @override
  void initState() {
    super.initState();
    initializeVLCPlayer();
    testServerConnection();
    initializeAudioStreams();
    requestMicrophonePermission();
    notifyServerScreenOpened();
  }

  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  void initializeVLCPlayer() {
    _vlcPlayerController = VlcPlayerController.network(
      'http://192.168.1.106:5000/video_feed',
      autoPlay: false,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(1000),
          VlcAdvancedOptions.liveCaching(1000),
          VlcAdvancedOptions.fileCaching(1000),
          VlcAdvancedOptions.clockJitter(0),
        ]),
      ),
    );

    _vlcPlayerController.addListener(() {
      if (_vlcPlayerController.value.isInitialized) {
        setState(() {
          _isInitialized = true;
        });
        if (_connectionTestMessage == "Connection successful") {
          playVideo();
        }
      } else if (_vlcPlayerController.value.hasError) {
        setState(() {
          _connectionTestMessage = "VLC Player Error: ${_vlcPlayerController.value.errorDescription}";
        });
      }
    });
  }

  Future<void> testServerConnection() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.106:5000/test_connection'));
      if (response.statusCode == 200) {
        setState(() {
          _connectionTestMessage = "Connection successful";
          _isLoading = false;
        });
        if (_isInitialized) {
          playVideo();
        }
      } else {
        setState(() {
          _connectionTestMessage = "Failed to connect to server";
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _connectionTestMessage = "Error connecting to server: $error";
        _isLoading = false;
      });
    }
  }

  void initializeAudioStreams() {
    _audioOutChannel = IOWebSocketChannel.connect('ws://192.168.1.106:5003');

    // Listen for incoming audio
    _audioOutChannel.stream.listen((data) async {
      if (_isMicActive) {
        debugPrint("Received audio data: ${data.length} bytes");
        await playAudioData(data);
      }
    }, onError: (error) {
      debugPrint("Error receiving audio data: $error");
    });
  }

  Future<void> playAudioData(Uint8List data) async {
    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/audio_data.pcm';
      final audioFile = File(path);
      await audioFile.writeAsBytes(data);

      // Convert PCM to WAV
      final wavPath = path.replaceAll('.pcm', '.wav');
      await _ffmpeg.execute('-f s16le -ar 44100 -ac 1 -i $path $wavPath');

      await _audioPlayer.play(DeviceFileSource(wavPath));
    } catch (e) {
      debugPrint("Error playing audio data: $e");
    }
  }

  void playVideo() {
    if (_vlcPlayerController.value.isInitialized) {
      try {
        _vlcPlayerController.play();
      } catch (e) {
        debugPrint("Error playing video: $e");
      }
    }
  }

  void toggleMic() async {
    setState(() {
      _isMicActive = !_isMicActive;
    });

    final url = _isMicActive
        ? 'http://192.168.1.106:5000/start_audio_stream'
        : 'http://192.168.1.106:5000/stop_audio_stream';

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        debugPrint(_isMicActive ? "Microphone activated" : "Microphone muted");
      } else {
        debugPrint("Failed to toggle microphone: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error toggling microphone: $e");
    }
  }

  Future<void> notifyServerScreenOpened() async {
    try {
      final response = await http.post(Uri.parse('http://192.168.1.106:5000/start_video_feed'));
      debugPrint("Start video feed response: ${response.statusCode}");
      if (response.statusCode == 200) {
        debugPrint("Server notified that monitor screen is opened");
      } else {
        debugPrint("Failed to notify server: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error notifying server: $e");
    }
  }

  Future<void> notifyServerScreenClosed() async {
    try {
      final response = await http.post(Uri.parse('http://192.168.1.106:5000/stop_video_feed'));
      debugPrint("Stop video feed response: ${response.statusCode}");
      if (response.statusCode == 200) {
        debugPrint("Server notified that monitor screen is closed");
      } else {
        debugPrint("Failed to notify server: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error notifying server: $e");
    }
  }

  @override
  void dispose() {
    notifyServerScreenClosed();
    _vlcPlayerController.dispose();
    _audioOutChannel.sink.close();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(titleText: 'Monitoring'),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(_connectionTestMessage),
                ],
              )
            : _connectionTestMessage == "Connection successful"
                ? Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SizedBox(
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              child: VlcPlayer(
                                controller: _vlcPlayerController,
                                aspectRatio: constraints.maxWidth / constraints.maxHeight,
                                placeholder: const Center(child: CircularProgressIndicator()),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: toggleMic,
                          child: Text(_isMicActive ? "Mute Microphone" : "Activate Microphone"),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(_connectionTestMessage),
                    ],
                  ),
      ),
    );
  }
}

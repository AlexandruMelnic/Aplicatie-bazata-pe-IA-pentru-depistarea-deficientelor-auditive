import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FrequencyRecognitionTestScreen extends StatefulWidget {
  @override
  _FrequencyRecognitionTestScreenState createState() => _FrequencyRecognitionTestScreenState();
}

class _FrequencyRecognitionTestScreenState extends State<FrequencyRecognitionTestScreen> {
  final List<int> frequencies = [300, 400, 500, 600, 700, 1000, 4000, 5000, 7000];
  final Map<int, bool> heardResults = {};
  final AudioPlayer _player = AudioPlayer();

  int _currentIndex = 0;
  bool _isPlaying = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playTone(int freq) async {
    String assetPath = 'assets/test5/pure_tone_${freq}_Hz.mp3';
    try {
      await _player.setAsset(assetPath);
      await _player.play();
      setState(() {
        _isPlaying = true;
      });
      await _player.playerStateStream.firstWhere((state) => state.processingState == ProcessingState.completed);
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      print('Eroare la redare: $e');
    }
  }

  void _submitResults() async {
    await FirebaseFirestore.instance.collection('feedback').add({
      'timestamp': DateTime.now(),
      'frequency_results': heardResults,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rezultatele au fost salvate!')));
  }

  @override
  Widget build(BuildContext context) {
    int freq = frequencies[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Test Recunoaștere Frecvențe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Frecvență curentă: $freq Hz', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isPlaying ? null : () => _playTone(freq),
              child: Text('Redă sunetul'),
            ),
            SizedBox(height: 20),
            Text('Ai auzit sunetul?', style: TextStyle(fontSize: 18)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    heardResults[freq] = true;
                    _nextFrequency();
                  },
                  child: Text('Da'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    heardResults[freq] = false;
                    _nextFrequency();
                  },
                  child: Text('Nu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _nextFrequency() {
    if (_currentIndex < frequencies.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _submitResults();
    }
  }
}

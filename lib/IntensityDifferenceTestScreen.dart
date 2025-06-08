import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IntensityDifferenceTestScreen extends StatefulWidget {
  @override
  _IntensityDifferenceTestScreenState createState() =>
      _IntensityDifferenceTestScreenState();
}

class _IntensityDifferenceTestScreenState
    extends State<IntensityDifferenceTestScreen> {
  final AudioPlayer _player = AudioPlayer();
  final List<int> frequencies = [300, 500, 1000]; // Frecvențele testate
  final List<double> intensityDifferences = [0.5, 1.0, 1.5]; // Diferențe de intensitate

  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isCorrect = false;
  double _volume = 1.0;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playTone(int freq, double volume) async {
    String assetPath = 'assets/test5/pure_tone_${freq}_Hz.mp3'; // calea către fișierul audio

    try {
      await _player.setAsset(assetPath);
      await _player.setVolume(volume); // Setează volumul în funcție de diferența de intensitate
      await _player.play();
      setState(() {
        _isPlaying = true;
      });
      await _player.playerStateStream.firstWhere(
              (state) => state.processingState == ProcessingState.completed);
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      print('Eroare la redare: $e');
    }
  }

  void _submitResults(int freq, double difference, bool isCorrect) async {
    // Salvăm rezultatul în Firestore cu detalii despre frecvență și corectitudine
    await FirebaseFirestore.instance.collection('feedback').add({
      'timestamp': DateTime.now(),
      'frequency': freq,
      'intensity_difference': difference,
      'correct_answer': isCorrect,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Rezultatul a fost salvat!')));
  }

  @override
  Widget build(BuildContext context) {
    int freq = frequencies[_currentIndex];
    double difference = intensityDifferences[_currentIndex % intensityDifferences.length];

    return Scaffold(
      appBar: AppBar(title: Text('Test de Detecție a Diferențelor de Intensitate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Frecvența curentă: $freq Hz', style: TextStyle(fontSize: 20)),
            SizedBox(height: 30),
            Text('Diferență de intensitate: x$difference', style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isPlaying ? null : () => _playTone(freq, 1.0), // Sunet la intensitate normală
              child: Text('Redă sunetul normal'),
            ),
            ElevatedButton(
              onPressed: _isPlaying ? null : () => _playTone(freq, difference), // Sunet cu intensitate modificată
              child: Text('Redă sunetul mai tare'),
            ),
            SizedBox(height: 20),
            Text('Care dintre sunete este mai tare?', style: TextStyle(fontSize: 18)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isCorrect = true; // Alegerea corectă
                    });
                    _nextTest(freq, difference); // Trimite frecvența și intensitatea la următorul test
                  },
                  child: Text('Primul sunet este mai tare'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isCorrect = false; // Alegerea greșită
                    });
                    _nextTest(freq, difference); // Trimite frecvența și intensitatea la următorul test
                  },
                  child: Text('Al doilea sunet este mai tare'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _nextTest(int freq, double difference) {
    // Salvăm răspunsul pentru fiecare test
    _submitResults(freq, difference, _isCorrect);

    if (_currentIndex < frequencies.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      setState(() {
        _isCorrect = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Testul s-a încheiat')));
    }
  }
}

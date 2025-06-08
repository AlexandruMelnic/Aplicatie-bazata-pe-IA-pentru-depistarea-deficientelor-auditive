import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuditoryMaskingTestScreen extends StatefulWidget {
  @override
  _AuditoryMaskingTestScreenState createState() =>
      _AuditoryMaskingTestScreenState();
}

class _AuditoryMaskingTestScreenState extends State<AuditoryMaskingTestScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingTone = false;
  double _noiseVolume = 0.5;
  double _toneVolume = 0.3;
  bool _heardTone = false;

  // Colecția Firestore pentru feedback
  final CollectionReference feedbackCollection = FirebaseFirestore.instance.collection('feedback');

  // Redă tonul pur
  Future<void> _playPureTone() async {
    if (!_isPlayingTone) {
      await _audioPlayer.play('assets/test7/puretone.mp3', volume: _toneVolume);
      setState(() {
        _isPlayingTone = true;
      });
    }
  }

  // Redă zgomotul de fundal
  Future<void> _playNoise() async {
    await _audioPlayer.play('assets/test7/backsound.mp3', volume: _noiseVolume);
  }

  void _startTest() {
    setState(() {
      _isPlayingTone = true;
      _playPureTone();
      _playNoise();
    });
  }

  void _adjustNoiseVolume(double value) {
    setState(() {
      _noiseVolume = value;
    });
  }

  void _markHeardTone(bool value) async {
    setState(() {
      _heardTone = value;
    });

    // Salvarea feedback-ului în Firestore
    try {
      await feedbackCollection.add({
        'heardTone': _heardTone,
        'toneVolume': _toneVolume,
        'noiseVolume': _noiseVolume,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Feedback salvat cu succes");
    } catch (e) {
      print("Eroare la salvarea feedback-ului: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Testul de Mascare Auditivă')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ajustează volumul zgomotului de fundal',
              style: TextStyle(fontSize: 18),
            ),
            Slider(
              value: _noiseVolume,
              min: 0.0,
              max: 1.0,
              onChanged: _adjustNoiseVolume,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startTest,
              child: Text('Începe testul'),
            ),
            SizedBox(height: 20),
            Text(
              _heardTone ? 'Ai auzit tonul!' : 'Nu ai auzit tonul.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _markHeardTone(true),
              child: Text('Da, am auzit tonul'),
            ),
            ElevatedButton(
              onPressed: () => _markHeardTone(false),
              child: Text('Nu, nu am auzit tonul'),
            ),
          ],
        ),
      ),
    );
  }
}

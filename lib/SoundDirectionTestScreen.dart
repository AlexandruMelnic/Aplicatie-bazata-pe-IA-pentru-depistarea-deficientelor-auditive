import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SoundDirectionTestScreen extends StatefulWidget {
  @override
  _SoundDirectionTestScreenState createState() =>
      _SoundDirectionTestScreenState();
}

class _SoundDirectionTestScreenState extends State<SoundDirectionTestScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final CollectionReference feedbackCollection =
  FirebaseFirestore.instance.collection('feedback'); // Colecția Firestore
  String feedbackMessage = "";
  String? correctDirection;
  String? selectedDirection;

  final Map<String, double> volumeLevels = {
    'Încet': 0.2,
    'Mediu': 0.5,
    'Tare': 1.0,
  };

  final List<String> directions = ['Stânga', 'Centru', 'Dreapta'];

  final Map<String, String> soundFiles = {
    'Încet': 'assets/test4/Incet.mp3',
    'Mediu': 'assets/test4/Incet.mp3',
    'Tare': 'assets/test4/Incet.mp3',
  };

  void playSound(String volume) async {
    setState(() {
      correctDirection = directions[(DateTime.now().millisecondsSinceEpoch % 3)];
    });

    try {
      await _audioPlayer.setAsset(soundFiles[volume]!);
      _audioPlayer.setVolume(volumeLevels[volume]!);
      await _audioPlayer.play();
    } catch (e) {
      print("Eroare la redare: $e");
    }
  }

  void recordFeedback(bool isCorrect) async {
    if (selectedDirection == null || correctDirection == null) return;

    try {
      await feedbackCollection.add({
        'selectedDirection': selectedDirection,
        'correctDirection': correctDirection,
        'isCorrect': isCorrect,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        feedbackMessage =
        isCorrect ? 'Corect!' : 'Greșit! Direcția corectă era $correctDirection.';
      });
      print("Feedback salvat în Firestore");
    } catch (e) {
      setState(() {
        feedbackMessage = 'Eroare la salvare feedback: $e';
      });
      print("Eroare la salvare feedback: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test de Direcționare a Sunetului")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Alege un volum:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: volumeLevels.keys.map((volume) {
                return ElevatedButton(
                  onPressed: () => playSound(volume),
                  child: Text(volume),
                );
              }).toList(),
            ),
            SizedBox(height: 30),
            Text(
              'Alege direcția sursei sonore:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: directions.map((direction) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedDirection = direction;
                    });
                  },
                  child: Text(direction),
                );
              }).toList(),
            ),
            SizedBox(height: 30),

            // Afișează direcția corectă aleatorie înainte de a apăsa butonul
            if (correctDirection != null)
              Text(
                'Direcția corectă este: $correctDirection',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),

            SizedBox(height: 30),
            // Butoane pentru a marca răspunsul corect sau greșit
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: selectedDirection == null
                      ? null
                      : () {
                    if (selectedDirection == correctDirection) {
                      recordFeedback(true);
                    } else {
                      recordFeedback(false);
                    }
                  },
                  child: Text("Corect"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: selectedDirection == null
                      ? null
                      : () {
                    if (selectedDirection != correctDirection) {
                      recordFeedback(false);
                    } else {
                      recordFeedback(true);
                    }
                  },
                  child: Text("Greșit"),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              feedbackMessage,
              style: TextStyle(fontSize: 16, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'audiogram_screen.dart';

class PureToneTestScreen extends StatefulWidget {
  @override
  _PureToneTestScreenState createState() => _PureToneTestScreenState();
}

class _PureToneTestScreenState extends State<PureToneTestScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<int> frequencies = [300, 400, 500, 600, 700, 1000, 4000, 5000, 7000];
  int selectedFrequency = 1000;
  String feedbackMessage = "";

  final CollectionReference feedbackCollection = FirebaseFirestore.instance.collection('feedback');

  void playTone() async {
    String fileName = 'pure_tone_${selectedFrequency}_Hz.mp3';
    try {
      await _audioPlayer.setAsset('assets/tones/$fileName');
      _audioPlayer.play();
    } catch (e) {
      print("Eroare la redarea audio: $e");
    }
  }

  void recordFeedback(String feedback, int score, String ear) async {
    setState(() {
      feedbackMessage = feedback;
    });

    try {
      await feedbackCollection.add({
        'frequency': selectedFrequency,
        'feedback': feedback,
        'score': score,
        'ear': ear,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        feedbackMessage = "$feedback (Salvat cu succes)";
      });
    } catch (error) {
      setState(() {
        feedbackMessage = "$feedback (Eroare: $error)";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Testul tonurilor pure")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Selectează frecvența:"),
          DropdownButton<int>(
            value: selectedFrequency,
            onChanged: (int? newValue) {
              setState(() {
                selectedFrequency = newValue!;
                feedbackMessage = ""; // Reset feedback când se schimbă frecvența
              });
            },
            items: frequencies.map((int frequency) {
              return DropdownMenuItem<int>(
                value: frequency,
                child: Text("${frequency} Hz"),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: playTone,
            child: Text("Redă tonul"),
          ),
          SizedBox(height: 20),
          Text(
            feedbackMessage.isEmpty ? "Aștept să dai feedback..." : feedbackMessage,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          // Butoane pentru feedback cu scoruri și ureche
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => recordFeedback("Auz clar", 20, "dreapta"),
                child: Text("Auz clar – Dreapta"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => recordFeedback("L-am auzit vag", 50, "dreapta"),
                child: Text("Vag – Dreapta"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => recordFeedback("Nu am auzit", 90, "dreapta"),
                child: Text("Nimic – Dreapta"),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => recordFeedback("Auz clar", 20, "stanga"),
                child: Text("Auz clar – Stânga"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => recordFeedback("L-am auzit vag", 50, "stanga"),
                child: Text("Vag – Stânga"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => recordFeedback("Nu am auzit", 90, "stanga"),
                child: Text("Nimic – Stânga"),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AudiogramScreen()),
              );
            },
            child: Text("Vezi Audiograma"),
          ),
        ],
      ),
    );
  }
}

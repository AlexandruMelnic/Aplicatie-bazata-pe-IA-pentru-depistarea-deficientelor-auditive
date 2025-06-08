import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SpeechInNoiseTestScreen extends StatefulWidget {
  @override
  _SpeechInNoiseTestScreenState createState() =>
      _SpeechInNoiseTestScreenState();
}

class _SpeechInNoiseTestScreenState extends State<SpeechInNoiseTestScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final CollectionReference feedbackCollection =
  FirebaseFirestore.instance.collection('feedback');

  int currentTestIndex = 0;
  String? selectedNumber;
  Map<String, String?> testResults = {};

  final List<String> tests = [
    'test3.8.mp3',
    'test3.4.mp3',
    'test3.7.mp3',
    'test3.2.mp3'
  ];

  final List<String> numbers = ['8', '4', '7', '2'];

  void playAudio() async {
    if (currentTestIndex < tests.length) {
      String test = tests[currentTestIndex];
      try {
        await _audioPlayer.setAsset('assets/test3/$test');
        _audioPlayer.play();
      } catch (e) {
        print("Eroare la redare: $e");
      }
    }
  }

  void nextTest(String response) {
    if (currentTestIndex < tests.length) {
      testResults[tests[currentTestIndex]] = response;
      setState(() {
        selectedNumber = null;
        currentTestIndex++;
      });

      if (currentTestIndex < tests.length) {
        playAudio();
      } else {
        saveResults();
      }
    }
  }

  void saveResults() async {
    try {
      await feedbackCollection.add({
        'results': testResults,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        currentTestIndex = 0;
        testResults.clear();
      });

      print("Rezultatele salvate în Firebase!");
    } catch (error) {
      print("Eroare la salvare: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Testul vorbirii în zgomot")),
      body: currentTestIndex < tests.length
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Test ${currentTestIndex + 1}/${tests.length}: ${tests[currentTestIndex]}"),
          SizedBox(height: 10),
          ElevatedButton(onPressed: playAudio, child: Text("Play")),
          SizedBox(height: 20),
          Text("Ce număr ai auzit?"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: numbers.map((number) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedNumber = number;
                  });
                },
                child: Text(number),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: selectedNumber != null
                    ? () => nextTest("Auzit: $selectedNumber")
                    : null,
                child: Text("Am auzit"),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => nextTest("Nu am auzit"),
                child: Text("Nu am auzit"),
              ),
            ],
          ),
        ],
      )
          : Center(child: Text("Test finalizat! Rezultatele sunt salvate.")),
    );
  }
}

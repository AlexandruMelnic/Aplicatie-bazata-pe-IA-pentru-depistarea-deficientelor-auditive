import 'package:flutter/material.dart';
import 'PureToneTestScreen.dart';
import 'TestScreen.dart';
import 'TheWhisperedWordsTest.dart';
import 'SpeechInNoiseTestScreen.dart';
import 'SoundDirectionTestScreen.dart';
import 'FrequencyRecognitionTestScreen.dart';
import 'IntensityDifferenceTestScreen.dart';
import 'AuditoryMaskingTestScreen.dart';
import 'EnvironmentalSoundRecognitionTestScreen.dart';
import 'chatbot_screen.dart';

class TestSelectionScreen extends StatefulWidget {
  @override
  _TestSelectionScreenState createState() => _TestSelectionScreenState();
}

class _TestSelectionScreenState extends State<TestSelectionScreen> {
  bool isAuthenticated = false;

  void toggleAuthentication() {
    setState(() {
      isAuthenticated = !isAuthenticated;
    });
  }

  final List<String> tests = [
    "Testul tonurilor pure",
    "Testul cuvintele șoptite",
    "Testul vorbirii în zgomot",
    "Testul de direcționare a sunetului",
    "Testul de recunoaștere a frecvențelor",
    "Testul de detecție a diferențelor de intensitate",
    "Testul de recunoaștere a sunetelor ambientale",
    "Testul de mascare auditivă",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alege un test auditiv'),
        actions: [
          IconButton(
            icon: Icon(isAuthenticated ? Icons.logout : Icons.login),
            tooltip: isAuthenticated ? 'Ieșire' : 'Autentificare',
            onPressed: toggleAuthentication,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tests.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tests[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => tests[index] == "Testul tonurilor pure"
                      ? PureToneTestScreen()
                      : tests[index] == "Testul cuvintele șoptite"
                      ? WhisperedWordsTestScreen()
                      : tests[index] == "Testul vorbirii în zgomot"
                      ? SpeechInNoiseTestScreen()
                      : tests[index] == "Testul de direcționare a sunetului"
                      ? SoundDirectionTestScreen()
                      : tests[index] == "Testul de recunoaștere a frecvențelor"
                      ? FrequencyRecognitionTestScreen()
                      : tests[index] == "Testul de detecție a diferențelor de intensitate"
                      ? IntensityDifferenceTestScreen()
                      : tests[index] == "Testul de recunoaștere a sunetelor ambientale"
                      ? EnvironmentalSoundRecognitionTestScreen()
                      : tests[index] == "Testul de mascare auditivă"
                      ? AuditoryMaskingTestScreen()
                      : TestScreen(testName: tests[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: SizedBox(
        height: 80,
        width: 80,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatBotScreen()),
            );
          },
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.chat, size: 36),
          tooltip: 'Deschide Chat Bot Auditiv',
        ),
      ),
    );
  }
}


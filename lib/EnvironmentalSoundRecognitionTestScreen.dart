import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnvironmentalSoundRecognitionTestScreen extends StatefulWidget {
  @override
  _EnvironmentalSoundRecognitionTestScreenState createState() => _EnvironmentalSoundRecognitionTestScreenState();
}

class _EnvironmentalSoundRecognitionTestScreenState extends State<EnvironmentalSoundRecognitionTestScreen> {
  final AudioPlayer _player = AudioPlayer();
  final List<String> soundFiles = [
    'assets/test6/car.mp3',
    'assets/test6/ploaie.mp3',
    'assets/test6/pasare.mp3',
    'assets/test6/vant.mp3',
  ];
  final List<String> soundNames = [
    'Claxon de mașină',
    'Ploaie',
    'Pasăre',
    'Vânt',
  ];

  int _currentIndex = 0;
  bool _isPlaying = false;
  String _selectedSound = '';

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playSound(String soundFile) async {
    try {
      await _player.setAsset(soundFile);
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

  void _submitResults(bool isCorrect) async {
    await FirebaseFirestore.instance.collection('feedback').add({
      'timestamp': DateTime.now(),
      'correct_answer': isCorrect,
      'sound': soundNames[_currentIndex],
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rezultatul a fost salvat!')));
  }

  void _nextTest() {
    if (_currentIndex < soundFiles.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedSound = '';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Testul s-a încheiat')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Testul de Recunoaștere a Sunetelor Ambientale')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sunetul curent: ${soundNames[_currentIndex]}', style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isPlaying ? null : () => _playSound(soundFiles[_currentIndex]),
                child: Text('Redă sunetul'),
              ),
              SizedBox(height: 40),
              Text(
                'Care dintre următoarele sunete credeți că ați auzit?',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Column(
                children: List.generate(soundNames.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 250, // <- ajustează aici cât de lat să fie butonul
                        child: ElevatedButton(
                          onPressed: _isPlaying ? null : () {
                            setState(() {
                              _selectedSound = soundNames[index];
                            });

                            bool isCorrect = _selectedSound == soundNames[_currentIndex];
                            _submitResults(isCorrect);
                            _nextTest();
                          },
                          child: Text(
                            soundNames[index],
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

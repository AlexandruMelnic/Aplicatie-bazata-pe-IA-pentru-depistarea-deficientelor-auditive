import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Importă Firebase Firestore

class WhisperedWordsTestScreen extends StatefulWidget {
  @override
  _WhisperedWordsTestScreenState createState() =>
      _WhisperedWordsTestScreenState();
}

class _WhisperedWordsTestScreenState extends State<WhisperedWordsTestScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? selectedWord;
  String feedbackMessage = "";
  bool isPlaying = false;  // Variabilă pentru a urmări starea de redare a audio-ului
  Duration currentPosition = Duration.zero; // Variabilă pentru a salva poziția curentă

  // Referința la colecția Firestore pentru a stoca feedback-ul
  final CollectionReference feedbackCollection =
  FirebaseFirestore.instance.collection('feedback');

  // Lista de cuvinte pentru test
  final List<String> words = ['oglindă', 'prosop', 'rățușcă de baie', 'burete', 'șampon'];

  // Funcția de redare/oprire a audio-ului
  void toggleAudio() async {
    if (isPlaying) {
      await _audioPlayer.stop();  // Oprește audio-ul dacă este în redare
    } else {
      String fileName = 'test2.mp3';  // Folosește fișierul audio corespunzător din assets
      try {
        await _audioPlayer.setAsset('assets/test2/$fileName');
        await _audioPlayer.setVolume(0.1);
        if (currentPosition != Duration.zero) {
          await _audioPlayer.seek(currentPosition);  // Sari la poziția salvată
        }
        await _audioPlayer.play();
      } catch (e) {
        print("Eroare la redarea audio: $e");
      }
    }

    setState(() {
      isPlaying = !isPlaying;  // Schimbă starea de redare
    });
  }

  // Înregistrarea feedback-ului în Firestore
  void recordFeedback(String feedback) async {
    setState(() {
      feedbackMessage = feedback;
    });

    try {
      // Salvează feedback-ul în Firestore
      await feedbackCollection.add({
        'selectedWord': selectedWord,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Adaugă un mesaj de confirmare
      setState(() {
        feedbackMessage = "$feedback (Salvat cu succes în baza de date)";
      });

      print("Feedback salvat în Firebase");
    } catch (error) {
      // Afișează eroarea dacă salvarea eșuează
      setState(() {
        feedbackMessage = "$feedback (Eroare la salvare: $error)";
      });

      print("Eroare la salvarea feedback-ului: $error");
    }
  }

  @override
  void initState() {
    super.initState();

    // Adăugăm un listener pentru a actualiza starea audio-ului când se schimbă
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          isPlaying = false; // Redarea s-a încheiat
          currentPosition = Duration.zero; // Resetăm poziția la final
        });
      }
    });

    // Ascultă schimbările poziției audio-ului pentru a salva poziția curentă
    _audioPlayer.positionStream.listen((position) {
      if (isPlaying) {
        setState(() {
          currentPosition = position;  // Salvează poziția curentă
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Testul cuvintele șoptite")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Alege cuvântul care crezi că ai auzit:"),
          SizedBox(height: 20),
          // Butonul Play/Stop pentru audio
          ElevatedButton(
            onPressed: toggleAudio,  // Va reda sau opri fișierul audio
            child: Text(isPlaying ? "Stop" : "Play"),  // Schimbă textul în funcție de starea audio-ului
          ),
          SizedBox(height: 20),
          // Butoanele pentru a alege cuvintele - acestea doar setează selectedWord
          for (int i = 0; i < words.length; i++) ...[
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedWord = words[i];
                });
              },
              child: Text(words[i]),
            ),
            SizedBox(height: 8), // Lasă spațiu între butoane
          ],
          SizedBox(height: 12),
          Text(
            feedbackMessage.isEmpty
                ? "Aștept să dai feedback..."
                : feedbackMessage,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Butoanele pentru feedback - doar pentru a înregistra răspunsul
              ElevatedButton(
                onPressed: () => recordFeedback("Am auzit cuvântul: $selectedWord"),
                child: Text("Am auzit"),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => recordFeedback("Nu am auzit cuvântul."),
                child: Text("Nu am auzit"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

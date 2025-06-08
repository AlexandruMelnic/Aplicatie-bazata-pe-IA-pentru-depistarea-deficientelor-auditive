import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AudiogramScreen extends StatefulWidget {
  @override
  _AudiogramScreenState createState() => _AudiogramScreenState();
}

class _AudiogramScreenState extends State<AudiogramScreen> {
  List<Map<String, dynamic>> feedbackList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    var data = await FirebaseFirestore.instance.collection('feedback').get();
    setState(() {
      feedbackList = data.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Audiograma")),
      body: Center(
        child: Column(
          children: [
            Text(
              'Audiograma - Stânga/Dreapta',
              style: TextStyle(fontSize: 24),
            ),
            Expanded(
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                painter: AudiogramPainter(feedbackList),
              ),
            ),
            // Legenda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text("X - Urechea stângă", style: TextStyle(fontSize: 14)),
                      SizedBox(width: 20),
                      Text("O - Urechea dreaptă", style: TextStyle(fontSize: 14)),
                    ],
                  )
                ],
              ),
            ),
            // Legenda pentru culori
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 12, height: 12, color: Colors.green),
                  SizedBox(width: 5),
                  Text("Auz clar", style: TextStyle(fontSize: 12)),
                  SizedBox(width: 15),
                  Container(width: 12, height: 12, color: Colors.orange),
                  SizedBox(width: 5),
                  Text("Auz vag", style: TextStyle(fontSize: 12)),
                  SizedBox(width: 15),
                  Container(width: 12, height: 12, color: Colors.red),
                  SizedBox(width: 5),
                  Text("Nu am auzit", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AudiogramPainter extends CustomPainter {
  final List<Map<String, dynamic>> feedbackList;

  AudiogramPainter(this.feedbackList);

  // Functie care returnează culoarea în funcție de severitate
  Color getColorForSeverity(int score) {
    if (score <= 20) {
      return Colors.green; // Auz clar
    } else if (score <= 50) {
      return Colors.orange; // Auz vag
    } else {
      return Colors.red; // Nu am auzit
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint axisPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    Paint pointPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Desenăm axele
    canvas.drawLine(Offset(50, 50), Offset(50, size.height - 50), axisPaint);  // Axă Y (severitate)
    canvas.drawLine(Offset(50, size.height - 50), Offset(size.width - 50, size.height - 50), axisPaint);  // Axă X (frecvență)

    // Etichete pentru axa X (frecvențele)
    List<double> frequencies = [300, 400, 500, 600, 700, 1000, 4000, 5000, 7000];
    for (int i = 0; i < frequencies.length; i++) {
      double x = 50 + (i / (frequencies.length - 1)) * (size.width - 100);
      TextSpan span = TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 12),
          text: '${frequencies[i]} Hz'
      );
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 40));
    }

    // Etichete pentru axa Y (scoruri de severitate)
    for (int i = 0; i <= 100; i += 20) {
      double y = 50 + ((100 - i) / 100) * (size.height - 100);
      TextSpan span = TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 12),
          text: '$i'
      );
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr
      );
      tp.layout();
      tp.paint(canvas, Offset(30 - tp.width, y - tp.height / 2));
    }

    // Desenăm punctele pe audiogramă
    for (var feedback in feedbackList) {
      if (feedback.containsKey('frequency') && feedback.containsKey('score') && feedback.containsKey('ear')) {
        double frequency = feedback['frequency'].toDouble();
        int score = feedback['score'];
        String ear = feedback['ear']; // "stanga" sau "dreapta" conform PureToneTestScreen
        Color pointColor = getColorForSeverity(score);

        int freqIndex = frequencies.indexOf(frequency);
        if (freqIndex == -1) continue; // Skip if frequency not found

        double x = 50 + (freqIndex / (frequencies.length - 1)) * (size.width - 100);
        double y = 50 + ((100 - score) / 100) * (size.height - 100);

        pointPaint.color = pointColor;

        // Desenăm X pentru urechea stângă, O pentru cea dreaptă
        if (ear == "stanga") {
          // Desenăm un X
          canvas.drawLine(Offset(x - 6, y - 6), Offset(x + 6, y + 6), pointPaint);
          canvas.drawLine(Offset(x - 6, y + 6), Offset(x + 6, y - 6), pointPaint);
        } else if (ear == "dreapta") {
          // Desenăm un O
          canvas.drawCircle(Offset(x, y), 6, pointPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
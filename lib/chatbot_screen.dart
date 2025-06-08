import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool isLoading = false;
  bool isFetchingData = false;

  // Cheia API de la OpenRouter
  final String openRouterApiKey = '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';

  // Referința către colecția de feedback din Firestore
  final CollectionReference feedbackCollection = FirebaseFirestore.instance.collection('feedback');

  // Metoda pentru preluarea datelor din Firestore
  // Metoda pentru preluarea datelor din Firestore
  Future<String> _fetchFeedbackData() async {
    setState(() {
      isFetchingData = true;
    });

    try {
      final QuerySnapshot snapshot = await feedbackCollection.get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          isFetchingData = false;
        });
        return "Nu există date de feedback în baza de date.";
      }

      // Construiește un string formatat din datele de feedback
      StringBuffer feedbackData = StringBuffer();
      feedbackData.writeln("Datele de feedback din teste auditive:");

      snapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        feedbackData.writeln("\n--- Rezultat test #${doc.id} ---");

        data.forEach((key, value) {
          feedbackData.writeln("$key: $value");
        });
      });

      setState(() {
        isFetchingData = false;
      });

      return feedbackData.toString();
    } catch (e) {
      setState(() {
        isFetchingData = false;
      });
      return "Eroare la preluarea datelor: $e";
    }
  }

  // Funcție pentru a analiza feedbackul utilizând AI
  Future<void> _analyzeFeedback() async {
    setState(() {
      isLoading = true;
    });

    // Obține datele din Firestore
    final feedbackData = await _fetchFeedbackData();

    // Adaugă datele în chat ca un mesaj de la utilizator
    setState(() {
      messages.add({'role': 'user', 'text': "Analizează următoarele date din testele auditive și oferă o concluzie: \n\n$feedbackData"});
    });

    // Trimite datele către API
    final response = await _sendRequestToOpenAI("Analizează următoarele date din testele mele auditive și oferă o concluzie, recomandări și sfaturi: \n\n$feedbackData");

    // Adaugă răspunsul în chat
    setState(() {
      messages.add({'role': 'assistant', 'text': response});
      isLoading = false;
    });
  }

  Future<String> _sendRequestToOpenAI(String message) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openRouterApiKey',
    };

    final body = jsonEncode({
      'model': 'mistralai/mistral-7b-instruct',
      'messages': [
        {'role': 'system', 'content': 'You are a helpful assistant that explains things about hearing health in Romanian. When analyzing hearing test data, provide a comprehensive analysis, possible issues, and recommendations for the user.'},
        {'role': 'user', 'content': message},
      ],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        return 'Eroare de la model (status: ${response.statusCode})';
      }
    } catch (e) {
      return 'Eroare la cerere. Verifică conexiunea.';
    }
  }

  void _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'text': input});
      isLoading = true;
    });

    _controller.clear();

    final response = await _sendRequestToOpenAI(input);

    setState(() {
      messages.add({'role': 'assistant', 'text': response});
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Asistent Auditiv')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                bool isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          if (isFetchingData)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 10),
                  Text('Se preiau datele din Firestore...'),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _analyzeFeedback,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Analizează rezultatele testelor'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Întreabă ceva despre auz...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
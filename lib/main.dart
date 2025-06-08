import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'TestSelectionScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Test',
      home: FutureBuilder(
        future: Firebase.initializeApp(
          options: FirebaseOptions(
              apiKey: "AIzaSyBlEjltJ0Pju4AAtl1dfJRVlgpBeC8wkkk",
              authDomain: "teza-66e8b.firebaseapp.com",
              projectId: "teza-66e8b",
              storageBucket: "teza-66e8b.firebasestorage.app",
              messagingSenderId: "68354395824",
              appId: "1:68354395824:web:8e34f0cc1ef201b9af7575",
              measurementId: "G-QGXVMBDWQF"
          ),
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Eroare Firebase: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Hearing Test App',
              theme: ThemeData(primarySwatch: Colors.blue),
              home: TestSelectionScreen(),
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
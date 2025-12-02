import 'package:flutter/material.dart';
import 'game_state.dart';
import 'wordle_service.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const WordleApp());
}

class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  @override
  Widget build(BuildContext context) {
// Use 10.0.2.2 for Android emulator, localhost mapping.
    final service = WordleService('http://localhost:3000');
    return MaterialApp(
      title: 'Wordle Clone',
      theme: ThemeData.dark(),
      home: GameScreen(service: service),
    );
  }
}
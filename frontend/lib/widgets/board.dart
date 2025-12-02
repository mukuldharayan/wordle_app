import 'package:flutter/material.dart';

class Board extends StatelessWidget {
  final String targetWord;
  final List<String> guesses;
  final int maxAttempts;

  const Board({
    super.key,
    required this.targetWord,
    required this.guesses,
    required this.maxAttempts,
  });

  Color _tileColor(String guess, int index) {
    final char = guess[index];
    if (targetWord[index] == char) {
      return Colors.green;
    } else if (targetWord.contains(char)) {
      return Colors.orange;
    } else {
      return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordLength = targetWord.length;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxAttempts, (row) {
        final guess = row < guesses.length ? guesses[row] : '';
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(wordLength, (col) {
            final letter = col < guess.length ? guess[col] : '';
            return Container(
              margin: const EdgeInsets.all(4),
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: guess.isEmpty
                    ? Colors.transparent
                    : _tileColor(guess, col),
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
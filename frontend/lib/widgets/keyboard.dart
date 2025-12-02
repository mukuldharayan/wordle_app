import 'package:flutter/material.dart';

class Keyboard extends StatefulWidget {
  final void Function(String guess) onSubmitGuess;
  const Keyboard({super.key, required this.onSubmitGuess});

  @override
  State<Keyboard> createState() => _KeyboardState();
}

class _KeyboardState extends State<Keyboard> {
  String _currentInput = '';

  void _addLetter(String l) {
    setState(() {
      if (_currentInput.length < 5) {
        _currentInput += l;
      }
    });
  }

  void _delete() {
    setState(() {
      if (_currentInput.isNotEmpty) {
        _currentInput =
            _currentInput.substring(0, _currentInput.length - 1);
      }
    });
  }

  void _submit() {
    if (_currentInput.isEmpty) return;
    widget.onSubmitGuess(_currentInput);
    setState(() {
      _currentInput = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      'QWERTYUIOP',
      'ASDFGHJKL',
      'ZXCVBNM',
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Guess: $_currentInput'),
        ),
        ...rows.map(
              (row) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.split('').map((c) {
              return Padding(
                padding: const EdgeInsets.all(2.0),
                child: ElevatedButton(
                  onPressed: () => _addLetter(c),
                  child: Text(c),
                ),
              );
            }).toList(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _delete,
              child: const Icon(Icons.backspace),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('ENTER'),
            ),
          ],
        ),
      ],
    );
  }
}
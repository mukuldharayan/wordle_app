import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../game_state.dart';
import '../wordle_service.dart';
import '../widgets/board.dart';
import '../widgets/keyboard.dart';

class GameScreen extends StatefulWidget {
  final WordleService service;
  const GameScreen({super.key, required this.service});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const _prefsKey = 'wordle_game_state';
  GameState? _state;
  Timer? _timer;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _loadStateOrStartNew();
  }

  Future<void> _loadStateOrStartNew() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final saved = GameState.decode(raw);
    if (saved != null && !saved.isCompleted) {
      setState(() {
        _state = saved;
      });
      _startTime = DateTime.now();
      _startTimerIfNeeded();
    } else {
      await _startNewGame(GameMode.classic);
    }
  }

  Future<void> _startNewGame(GameMode mode) async {
    final apiMode = mode == GameMode.timed ? 'timed' : 'classic';
    final word = await widget.service.fetchWord(apiMode);
    final state = GameState(
      targetWord: word,
      guesses: [],
      maxAttempts: 6,
      isCompleted: false,
      isSuccess: false,
      mode: mode,
      remainingSeconds: mode == GameMode.timed ? 60 : 0,
    );
    _startTime = DateTime.now();
    setState(() {
      _state = state;
    });
    _startTimerIfNeeded();
    _saveState();
  }



  void _startTimerIfNeeded() {
    _timer?.cancel();
    if (_state != null &&
        _state!.mode == GameMode.timed &&
        !_state!.isCompleted) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_state == null) return;
        if (_state!.remainingSeconds <= 1) {
          _finishGame(success: false);
          t.cancel();
        } else {
          setState(() {
            _state = _state!.copyWith(
              remainingSeconds: _state!.remainingSeconds - 1,
            );
          });
          _saveState();
        }
      });
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_state != null) {
      await prefs.setString(_prefsKey, _state!.encode());
    } else {
      await prefs.remove(_prefsKey);
    }
  }

  void _onGuessSubmitted(String guess) {
    if (_state == null || _state!.isCompleted) return;
    if (guess.length != _state!.targetWord.length) return;
    final newGuesses =
    List<String>.from(_state!.guesses)..add(guess.toUpperCase());
    final isSuccess = guess.toUpperCase() == _state!.targetWord;
    final isCompleted = isSuccess || newGuesses.length >= _state!.maxAttempts;

    setState(() {
      _state = _state!.copyWith(
        guesses: newGuesses,
        isCompleted: isCompleted,
        isSuccess: isSuccess,
      );
    });
    _saveState();

    if (isCompleted) {
      _finishGame(success: isSuccess);
    }
  }

  Future<void> _finishGame({required bool success}) async {
    _timer?.cancel();
    final endTime = DateTime.now();
    final secs =
    _startTime == null ? 0 : endTime.difference(_startTime!).inSeconds;
    if (_state == null) return;
    await widget.service.submitScore(
      playerName: 'Player',
      mode: _state!.mode == GameMode.timed ? 'timed' : 'classic',
      attempts: _state!.guesses.length,
      success: success,
      timeTakenSeconds: secs,
    );
    await _saveState();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(success ? 'You win!' : 'Game over'),
          content: Text('Word was: ${_state!.targetWord}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGame(_state!.mode);
              },
              child: const Text('Play again'),
            ),
          ],
        );
      },
    );
  }

  void _pauseGame() {
    _timer?.cancel();
    _saveState();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Game paused')));
  }

  void _resumeGame() {
    _startTimerIfNeeded();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Game resumed')));
  }

  void _shareScore() {
    if (_state == null) return;
    final state = _state!;
    final buffer = StringBuffer();
    buffer.writeln(
        'Wordle Clone - ${state.mode == GameMode.timed ? 'Timed' : 'Classic'}');
    buffer.writeln(
        state.isSuccess ? 'Solved in ${state.guesses.length} attempts' : 'Failed');
    if (state.mode == GameMode.timed) {
      buffer.writeln('Time left: ${state.remainingSeconds}s');
    }
    buffer.writeln('Guesses:');
    for (final g in state.guesses) {
      buffer.writeln(g);
    }
    Share.share(buffer.toString());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    if (state == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wordle Clone'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: _pauseGame,
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _resumeGame,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareScore,
          ),
          PopupMenuButton<GameMode>(
            onSelected: (mode) async {
              _timer?.cancel();
              await _startNewGame(mode);
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                value: GameMode.classic,
                child: Text('Classic'),
              ),
              PopupMenuItem(
                value: GameMode.timed,
                child: Text('Timed (60s)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.mode == GameMode.timed)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Time left: ${state.remainingSeconds}s',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          Expanded(
            flex: 3,
            child: Board(
              targetWord: state.targetWord,
              guesses: state.guesses,
              maxAttempts: state.maxAttempts,
            ),
          ),
          Expanded(
            flex: 2,
            child: Keyboard(onSubmitGuess: _onGuessSubmitted),
          ),
        ],
      ),
    );
  }
}
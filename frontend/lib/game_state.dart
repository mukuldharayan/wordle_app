import 'dart:convert';

enum GameMode { classic, timed }

class GameState {
  final String targetWord;
  final List<String> guesses;
  final int maxAttempts;
  final bool isCompleted;
  final bool isSuccess;
  final GameMode mode;
  final int remainingSeconds;

  GameState({
    required this.targetWord,
    required this.guesses,
    required this.maxAttempts,
    required this.isCompleted,
    required this.isSuccess,
    required this.mode,
    required this.remainingSeconds,
  });

  GameState copyWith({
    String? targetWord,
    List<String>? guesses,
    int? maxAttempts,
    bool? isCompleted,
    bool? isSuccess,
    GameMode? mode,
    int? remainingSeconds,
  }) {
    return GameState(
      targetWord: targetWord ?? this.targetWord,
      guesses: guesses ?? this.guesses,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      isCompleted: isCompleted ?? this.isCompleted,
      isSuccess: isSuccess ?? this.isSuccess,
      mode: mode ?? this.mode,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetWord': targetWord,
      'guesses': guesses,
      'maxAttempts': maxAttempts,
      'isCompleted': isCompleted,
      'isSuccess': isSuccess,
      'mode': mode.toString(),
      'remainingSeconds': remainingSeconds,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      targetWord: json['targetWord'],
      guesses: List<String>.from(json['guesses']),
      maxAttempts: json['maxAttempts'],
      isCompleted: json['isCompleted'],
      isSuccess: json['isSuccess'],
      mode: json['mode'].toString().contains('timed')
          ? GameMode.timed
          : GameMode.classic,
      remainingSeconds: json['remainingSeconds'],
    );
  }

  String encode() => jsonEncode(toJson());

  static GameState? decode(String? raw) {
    if (raw == null) return null;
    return GameState.fromJson(jsonDecode(raw));
  }
}


import 'dart:convert';
import 'package:http/http.dart' as http;

class WordleService {
  final String baseUrl;
  WordleService(this.baseUrl);

  Future<String> fetchWord(String mode) async {
    // mode is 'classic' or 'timed'
    final uri = Uri.parse('$baseUrl/word/$mode');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load word: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body);
    final word = data['word'];
    if (word == null || word is! String) {
      throw Exception('Invalid response: $data');
    }
    return word.toUpperCase();
  }

  Future<void> submitScore({
    required String playerName,
    required String mode,
    required int attempts,
    required bool success,
    required int timeTakenSeconds,
  }) async {
    final uri = Uri.parse('$baseUrl/score');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'playerName': playerName,
        'mode': mode,
        'attempts': attempts,
        'success': success,
        'timeTakenSeconds': timeTakenSeconds,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to submit score');
    }
  }
}

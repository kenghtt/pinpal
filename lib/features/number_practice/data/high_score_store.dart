part of 'package:pinpal/main.dart';

class HighScoreStore {
  static const _highScoresKey = 'numberPracticeHighScores';

  Future<HighScores> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_highScoresKey);
    if (jsonString == null) {
      return HighScores.defaults;
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return HighScores.fromJson(decoded);
      }
    } on FormatException {
      return HighScores.defaults;
    }

    return HighScores.defaults;
  }

  Future<void> save(HighScores scores) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_highScoresKey, jsonEncode(scores.toJson()));
  }

  Future<HighScores> updatePracticeHighScore(int score) async {
    final scores = await load();
    if (score <= scores.practice) {
      return scores;
    }
    final updated = scores.copyWith(practice: score);
    await save(updated);
    return updated;
  }

  Future<HighScores> updatePasscodeHeroHighScore(int score) async {
    final scores = await load();
    if (score <= scores.passcodeHero) {
      return scores;
    }
    final updated = scores.copyWith(passcodeHero: score);
    await save(updated);
    return updated;
  }

  Future<HighScores> updateSpeedRunHighScore(int count, int timeMs) async {
    final scores = await load();
    final currentBest = scores.speedRunBestFor(count);
    if (currentBest != 0 && timeMs >= currentBest) {
      return scores;
    }

    final speedRun = Map<int, int>.of(scores.speedRun)..[count] = timeMs;
    final updated = scores.copyWith(speedRun: speedRun);
    await save(updated);
    return updated;
  }
}

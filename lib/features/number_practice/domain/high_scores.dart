part of 'package:pinpal/main.dart';

class HighScores {
  HighScores({
    this.practice = 0,
    this.passcodeHero = 0,
    Map<int, int>? speedRun,
  }) : speedRun = speedRun ?? _defaultSpeedRunScores();

  static HighScores get defaults => HighScores();

  final int practice;
  final int passcodeHero;
  final Map<int, int> speedRun;

  int speedRunBestFor(int count) => speedRun[count] ?? 0;

  HighScores copyWith({
    int? practice,
    int? passcodeHero,
    Map<int, int>? speedRun,
  }) {
    return HighScores(
      practice: practice ?? this.practice,
      passcodeHero: passcodeHero ?? this.passcodeHero,
      speedRun: speedRun ?? this.speedRun,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'practice': practice,
      'passcodeHero': passcodeHero,
      'speedRun': speedRun.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  factory HighScores.fromJson(Map<String, dynamic> json) {
    final speedRunJson = json['speedRun'];
    final speedRun = {25: 0, 50: 0, 75: 0, 100: 0};

    if (speedRunJson is Map<String, dynamic>) {
      for (final entry in speedRunJson.entries) {
        final count = int.tryParse(entry.key);
        final value = entry.value;
        if (count != null && value is int) {
          speedRun[count] = value;
        }
      }
    }

    return HighScores(
      practice: _readInt(json['practice']),
      passcodeHero: _readInt(json['passcodeHero']),
      speedRun: speedRun,
    );
  }

  static int _readInt(Object? value) => value is int ? value : 0;

  static Map<int, int> _defaultSpeedRunScores() => {
    25: 0,
    50: 0,
    75: 0,
    100: 0,
  };
}

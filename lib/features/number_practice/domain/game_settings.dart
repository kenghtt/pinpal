part of 'package:pinpal/main.dart';

class GameSettings {
  const GameSettings({
    required this.passcodeLength,
    required this.customPasscode,
    required this.isRandomMode,
    required this.speedRunCount,
    required this.showHints,
    required this.hapticFeedback,
  });

  final int passcodeLength;
  final String customPasscode;
  final bool isRandomMode;
  final int speedRunCount;
  final bool showHints;
  final bool hapticFeedback;

  String get paddedPasscode => customPasscode.padRight(passcodeLength, '0');

  static const defaults = GameSettings(
    passcodeLength: 4,
    customPasscode: '0000',
    isRandomMode: true,
    speedRunCount: 50,
    showHints: true,
    hapticFeedback: true,
  );

  GameSettings copyWith({
    int? passcodeLength,
    String? customPasscode,
    bool? isRandomMode,
    int? speedRunCount,
    bool? showHints,
    bool? hapticFeedback,
  }) {
    return GameSettings(
      passcodeLength: passcodeLength ?? this.passcodeLength,
      customPasscode: customPasscode ?? this.customPasscode,
      isRandomMode: isRandomMode ?? this.isRandomMode,
      speedRunCount: speedRunCount ?? this.speedRunCount,
      showHints: showHints ?? this.showHints,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }
}

part of 'package:pinpal/main.dart';

class GameSettingsStore {
  static const _passcodeKey = 'passcode';
  static const _isRandomKey = 'isRandom';
  static const _lengthKey = 'length';
  static const _speedRunCountKey = 'speedRunCount';
  static const _showHintsKey = 'showHints';
  static const _hapticFeedbackKey = 'hapticFeedback';

  Future<GameSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return GameSettings(
      passcodeLength:
          (prefs.getInt(_lengthKey) ?? GameSettings.defaults.passcodeLength)
              .clamp(3, 6),
      customPasscode:
          prefs.getString(_passcodeKey) ?? GameSettings.defaults.customPasscode,
      isRandomMode:
          prefs.getBool(_isRandomKey) ?? GameSettings.defaults.isRandomMode,
      speedRunCount:
          prefs.getInt(_speedRunCountKey) ??
          GameSettings.defaults.speedRunCount,
      showHints:
          prefs.getBool(_showHintsKey) ?? GameSettings.defaults.showHints,
      hapticFeedback:
          prefs.getBool(_hapticFeedbackKey) ??
          GameSettings.defaults.hapticFeedback,
    );
  }

  Future<void> save(GameSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passcodeKey, settings.customPasscode);
    await prefs.setBool(_isRandomKey, settings.isRandomMode);
    await prefs.setInt(_lengthKey, settings.passcodeLength);
    await prefs.setInt(_speedRunCountKey, settings.speedRunCount);
    await prefs.setBool(_showHintsKey, settings.showHints);
    await prefs.setBool(_hapticFeedbackKey, settings.hapticFeedback);
  }
}

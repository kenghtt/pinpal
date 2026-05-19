part of 'package:pinpal/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.initialSettings});

  final GameSettings initialSettings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _passcodeController;
  late int _passcodeLength;
  late bool _isRandomMode;
  late int _speedRunCount;
  late bool _showHints;
  late bool _hapticFeedback;

  @override
  void initState() {
    super.initState();
    final settings = widget.initialSettings;
    _passcodeLength = settings.passcodeLength;
    _isRandomMode = settings.isRandomMode;
    _speedRunCount = settings.speedRunCount;
    _showHints = settings.showHints;
    _hapticFeedback = settings.hapticFeedback;
    _passcodeController = TextEditingController(
      text: settings.paddedPasscode.substring(0, _passcodeLength),
    );
  }

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  void _syncPasscodeLength(int length) {
    setState(() {
      _passcodeLength = length.clamp(3, 6);
      final digits = _passcodeController.text.replaceAll(RegExp(r'[^0-9]'), '');
      _passcodeController.text = digits
          .padRight(_passcodeLength, '0')
          .substring(0, _passcodeLength);
    });
  }

  void _save() {
    Navigator.of(context).pop(
      GameSettings(
        passcodeLength: _passcodeLength,
        customPasscode: _passcodeController.text,
        isRandomMode: _isRandomMode,
        speedRunCount: _speedRunCount,
        showHints: _showHints,
        hapticFeedback: _hapticFeedback,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff7c3aed), Color(0xff9333ea), Color(0xffc026d3)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                      label: const Text('Back'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withAlpha(230),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customize your learning experience',
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          _SettingsCard(
                            title: 'Practice Mode',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _ModernFieldLabel('Passcode Length'),
                                DropdownButtonFormField<int>(
                                  initialValue: _passcodeLength,
                                  decoration: _settingsInputDecoration(),
                                  items: const [3, 4, 5, 6]
                                      .map(
                                        (value) => DropdownMenuItem<int>(
                                          value: value,
                                          child: Text('$value'),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      _syncPasscodeLength(value);
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                _ToggleRow(
                                  label: 'Random Passcodes',
                                  value: _isRandomMode,
                                  onChanged: (value) =>
                                      setState(() => _isRandomMode = value),
                                ),
                                if (!_isRandomMode) ...[
                                  const SizedBox(height: 16),
                                  const _ModernFieldLabel('Custom Passcode'),
                                  TextField(
                                    controller: _passcodeController,
                                    textAlign: TextAlign.center,
                                    maxLength: _passcodeLength,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(
                                        _passcodeLength,
                                      ),
                                    ],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      letterSpacing: 3,
                                    ),
                                    decoration: _settingsInputDecoration(
                                      hintText: '0000',
                                      counterText: '',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SettingsCard(
                            title: 'Speed Challenge',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _ModernFieldLabel('Number Count'),
                                DropdownButtonFormField<int>(
                                  initialValue: _speedRunCount,
                                  decoration: _settingsInputDecoration(),
                                  items: const [25, 50, 75, 100]
                                      .map(
                                        (value) => DropdownMenuItem<int>(
                                          value: value,
                                          child: Text('$value Numbers'),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _speedRunCount = value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SettingsCard(
                            title: 'Helper Features',
                            child: Column(
                              children: [
                                _FeatureToggleRow(
                                  icon: Icons.lightbulb_rounded,
                                  iconColor: const Color(0xffeab308),
                                  label: 'Show Hints',
                                  description:
                                      'Highlights the correct number after 10 seconds',
                                  value: _showHints,
                                  onChanged: (value) =>
                                      setState(() => _showHints = value),
                                ),
                                const Divider(height: 32),
                                _FeatureToggleRow(
                                  icon: Icons.vibration_rounded,
                                  iconColor: const Color(0xffa855f7),
                                  label: 'Haptic Feedback',
                                  description: 'Vibration on button presses',
                                  value: _hapticFeedback,
                                  onChanged: (value) =>
                                      setState(() => _hapticFeedback = value),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save_rounded, size: 20),
                          label: const Text('Save Settings'),
                          style: FilledButton.styleFrom(
                            foregroundColor: const Color(0xff9333ea),
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

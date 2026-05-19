import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const NumberPracticeApp());
}

enum GameMode { practice, speedRun }

enum FeedbackState { success, error }

class NumberPracticeApp extends StatelessWidget {
  const NumberPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Number Practice',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const SettingsScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff2563eb),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4),
      ),
    );
  }
}

class GameSettings {
  const GameSettings({
    required this.mode,
    required this.passcodeLength,
    required this.customPasscode,
    required this.isRandomMode,
    required this.speedRunCount,
    required this.showHints,
    required this.hapticFeedback,
  });

  final GameMode mode;
  final int passcodeLength;
  final String customPasscode;
  final bool isRandomMode;
  final int speedRunCount;
  final bool showHints;
  final bool hapticFeedback;

  String get paddedPasscode => customPasscode.padRight(passcodeLength, '0');
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _passcodeController = TextEditingController(
    text: '0000',
  );
  GameMode _mode = GameMode.practice;
  int _passcodeLength = 4;
  bool _isRandomMode = false;
  int _speedRunCount = 50;
  bool _showHints = true;
  bool _hapticFeedback = true;

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  void _start() {
    final settings = GameSettings(
      mode: _mode,
      passcodeLength: _passcodeLength,
      customPasscode: _passcodeController.text,
      isRandomMode: _isRandomMode,
      speedRunCount: _speedRunCount,
      showHints: _showHints,
      hapticFeedback: _hapticFeedback,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => switch (_mode) {
          GameMode.practice => PracticeScreen(settings: settings),
          GameMode.speedRun => SpeedRunScreen(settings: settings),
        },
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Number Practice',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: const Color(0xff030213),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help your little one learn numbers!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xff717182),
                    ),
                  ),
                  const SizedBox(height: 32),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withAlpha(26)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(18),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel('Game Mode'),
                          Row(
                            children: [
                              Expanded(
                                child: _ModeButton(
                                  icon: Icons.arrow_forward_rounded,
                                  label: 'Practice',
                                  selected: _mode == GameMode.practice,
                                  onTap: () =>
                                      setState(() => _mode = GameMode.practice),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ModeButton(
                                  icon: Icons.bolt_rounded,
                                  label: 'Speed Run',
                                  selected: _mode == GameMode.speedRun,
                                  onTap: () =>
                                      setState(() => _mode = GameMode.speedRun),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _mode == GameMode.practice
                                ? _PracticeSettings(
                                    key: const ValueKey('practice'),
                                    passcodeLength: _passcodeLength,
                                    passcodeController: _passcodeController,
                                    isRandomMode: _isRandomMode,
                                    onLengthChanged: _syncPasscodeLength,
                                    onRandomChanged: (value) =>
                                        setState(() => _isRandomMode = value),
                                  )
                                : _SpeedRunSettings(
                                    key: const ValueKey('speed'),
                                    count: _speedRunCount,
                                    onChanged: (value) =>
                                        setState(() => _speedRunCount = value),
                                  ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Divider(height: 1),
                          ),
                          _SettingsSwitch(
                            icon: Icons.lightbulb_rounded,
                            iconColor: const Color(0xffeab308),
                            title: 'Show Hints',
                            subtitle:
                                'Highlights the correct number after 10 seconds',
                            value: _showHints,
                            onChanged: (value) =>
                                setState(() => _showHints = value),
                          ),
                          const SizedBox(height: 18),
                          _SettingsSwitch(
                            icon: Icons.vibration_rounded,
                            iconColor: const Color(0xff3b82f6),
                            title: 'Haptic Feedback',
                            subtitle: 'Vibration on button presses',
                            value: _hapticFeedback,
                            onChanged: (value) =>
                                setState(() => _hapticFeedback = value),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xff030213),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _start,
                              icon: Icon(
                                _mode == GameMode.practice
                                    ? Icons.arrow_forward_rounded
                                    : Icons.bolt_rounded,
                              ),
                              label: Text(
                                _mode == GameMode.practice
                                    ? 'Start Practice'
                                    : 'Start Speed Run',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticeSettings extends StatelessWidget {
  const _PracticeSettings({
    super.key,
    required this.passcodeLength,
    required this.passcodeController,
    required this.isRandomMode,
    required this.onLengthChanged,
    required this.onRandomChanged,
  });

  final int passcodeLength;
  final TextEditingController passcodeController;
  final bool isRandomMode;
  final ValueChanged<int> onLengthChanged;
  final ValueChanged<bool> onRandomChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Passcode Length'),
        DropdownButtonFormField<int>(
          initialValue: passcodeLength,
          decoration: const InputDecoration(filled: true),
          items: const [3, 4, 5, 6]
              .map(
                (length) => DropdownMenuItem<int>(
                  value: length,
                  child: Text('$length digits'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onLengthChanged(value);
            }
          },
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('Random passcodes'),
          value: isRandomMode,
          onChanged: (value) => onRandomChanged(value ?? false),
        ),
        if (!isRandomMode) ...[
          const SizedBox(height: 8),
          const _SectionLabel('Practice Passcode'),
          TextField(
            controller: passcodeController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: passcodeLength,
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              filled: true,
              counterText: '',
              hintText: ''.padRight(passcodeLength, '0'),
            ),
            onChanged: (value) {
              if (value.length > passcodeLength) {
                passcodeController.text = value.substring(0, passcodeLength);
              }
            },
          ),
        ],
      ],
    );
  }
}

class _SpeedRunSettings extends StatelessWidget {
  const _SpeedRunSettings({
    super.key,
    required this.count,
    required this.onChanged,
  });

  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('How Many Numbers?'),
        DropdownButtonFormField<int>(
          initialValue: count,
          decoration: const InputDecoration(filled: true),
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
              onChanged(value);
            }
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Type as many numbers as you can! Wrong answers add +2 seconds penalty.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xff717182)),
        ),
      ],
    );
  }
}

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.settings});

  final GameSettings settings;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with TickerProviderStateMixin {
  final Random _random = Random();
  late final AnimationController _shakeController;
  late String _targetPasscode;
  String _input = '';
  FeedbackState? _feedback;
  int? _pressedNumber;
  int? _hintNumber;
  Timer? _hintTimer;
  Timer? _popUpTimer;
  Timer? _feedbackTimer;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _targetPasscode = _createPasscode();
    _restartHintTimer();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _popUpTimer?.cancel();
    _feedbackTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  String _createPasscode() {
    if (!widget.settings.isRandomMode) {
      return widget.settings.paddedPasscode;
    }

    return List.generate(
      widget.settings.passcodeLength,
      (_) => _random.nextInt(10),
    ).join();
  }

  void _restartHintTimer() {
    _hintTimer?.cancel();
    if (mounted) {
      setState(() => _hintNumber = null);
    }
    if (!widget.settings.showHints) {
      return;
    }
    _hintTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted ||
          _feedback != null ||
          _input.length >= _targetPasscode.length) {
        return;
      }
      setState(() => _hintNumber = int.parse(_targetPasscode[_input.length]));
    });
  }

  void _handleNumber(int number) {
    if (_feedback != null) {
      return;
    }
    _tapFeedback();
    _showPressedNumber(number);
    _restartHintTimer();

    final nextInput = '$_input$number';
    setState(() => _input = nextInput);

    if (nextInput.length == _targetPasscode.length) {
      _checkPasscode(nextInput);
    }
  }

  void _checkPasscode(String input) {
    if (input == _targetPasscode) {
      setState(() => _feedback = FeedbackState.success);
      _feedbackTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _targetPasscode = _createPasscode();
          _input = '';
          _feedback = null;
        });
        _restartHintTimer();
      });
      return;
    }

    setState(() => _feedback = FeedbackState.error);
    _shakeController.forward(from: 0);
    _feedbackTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _input = '';
        _feedback = null;
      });
      _restartHintTimer();
    });
  }

  void _delete() {
    if (_input.isEmpty || _feedback != null) {
      return;
    }
    _tapFeedback();
    setState(() {
      _input = _input.substring(0, _input.length - 1);
      _feedback = null;
    });
    _restartHintTimer();
  }

  void _tapFeedback() {
    if (widget.settings.hapticFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  void _showPressedNumber(int number) {
    _popUpTimer?.cancel();
    setState(() => _pressedNumber = number);
    _popUpTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _pressedNumber = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _BlackGameScaffold(
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Settings'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xff3b82f6),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Enter Passcode',
                        style: TextStyle(
                          color: Color(0xff9ca3af),
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FittedBox(
                        child: Text(
                          _targetPasscode,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xe6ffffff),
                            fontSize: 76,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 64),
                      AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(
                            _shakeOffset(_shakeController.value),
                            0,
                          ),
                          child: child,
                        ),
                        child: PasscodeDots(
                          count: _targetPasscode.length,
                          filled: _input.length,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 24,
                        child: _FeedbackText(feedback: _feedback),
                      ),
                    ],
                  ),
                ),
                NumberPad(
                  hintNumber: _hintNumber,
                  showDelete: true,
                  deleteEnabled: _input.isNotEmpty && _feedback == null,
                  disabled: _feedback != null,
                  onNumberPressed: _handleNumber,
                  onDelete: _delete,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_pressedNumber != null)
            PressedNumberOverlay(number: _pressedNumber!),
          if (_feedback == FeedbackState.success)
            const CelebrationOverlay(particleCount: 100),
        ],
      ),
    );
  }
}

class SpeedRunScreen extends StatefulWidget {
  const SpeedRunScreen({super.key, required this.settings});

  final GameSettings settings;

  @override
  State<SpeedRunScreen> createState() => _SpeedRunScreenState();
}

class _SpeedRunScreenState extends State<SpeedRunScreen>
    with TickerProviderStateMixin {
  final Random _random = Random();
  late final AnimationController _shakeController;
  late int _targetNumber;
  int _completed = 0;
  int _wrongAttempts = 0;
  int _elapsedMilliseconds = 0;
  bool _timerStarted = false;
  bool _wrongAnimation = false;
  int? _pressedNumber;
  int? _hintNumber;
  Timer? _speedTimer;
  Timer? _hintTimer;
  Timer? _popUpTimer;
  Timer? _wrongTimer;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _targetNumber = _random.nextInt(10);
    _restartHintTimer();
  }

  @override
  void dispose() {
    _speedTimer?.cancel();
    _hintTimer?.cancel();
    _popUpTimer?.cancel();
    _wrongTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startTimerIfNeeded() {
    if (_timerStarted) {
      return;
    }
    _timerStarted = true;
    _startTime = DateTime.now();
    _speedTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      if (!mounted || _startTime == null) {
        return;
      }
      setState(() {
        _elapsedMilliseconds = DateTime.now()
            .difference(_startTime!)
            .inMilliseconds;
      });
    });
  }

  void _restartHintTimer() {
    _hintTimer?.cancel();
    if (mounted) {
      setState(() => _hintNumber = null);
    }
    if (!widget.settings.showHints) {
      return;
    }
    _hintTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _hintNumber = _targetNumber);
      }
    });
  }

  void _handleNumber(int number) {
    _startTimerIfNeeded();
    if (widget.settings.hapticFeedback) {
      HapticFeedback.selectionClick();
    }
    _showPressedNumber(number);
    _restartHintTimer();

    if (number == _targetNumber) {
      final nextCompleted = _completed + 1;
      if (nextCompleted == widget.settings.speedRunCount) {
        _speedTimer?.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => SpeedRunResultsScreen(
              totalNumbers: widget.settings.speedRunCount,
              wrongAttempts: _wrongAttempts,
              elapsedMilliseconds: _elapsedMilliseconds,
            ),
          ),
        );
        return;
      }

      setState(() {
        _completed = nextCompleted;
        _targetNumber = _random.nextInt(10);
      });
      return;
    }

    setState(() {
      _wrongAttempts++;
      _wrongAnimation = true;
    });
    _shakeController.forward(from: 0);
    _wrongTimer?.cancel();
    _wrongTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _wrongAnimation = false);
      }
    });
  }

  void _showPressedNumber(int number) {
    _popUpTimer?.cancel();
    setState(() => _pressedNumber = number);
    _popUpTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _pressedNumber = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _completed / widget.settings.speedRunCount;

    return _BlackGameScaffold(
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(13),
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withAlpha(26)),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: const Text('Quit'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xff3b82f6),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.timer_rounded,
                              color: Color(0xfffacc15),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatStopwatch(_elapsedMilliseconds),
                              style: const TextStyle(
                                color: Color(0xfffacc15),
                                fontSize: 20,
                                fontFeatures: [FontFeature.tabularFigures()],
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _TopStat(
                              icon: Icons.track_changes_rounded,
                              iconColor: const Color(0xff22c55e),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$_completed',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/${widget.settings.speedRunCount}',
                                      style: const TextStyle(
                                        color: Color(0xff9ca3af),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _TopStat(
                              icon: Icons.bolt_rounded,
                              iconColor: const Color(0xffef4444),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$_wrongAttempts',
                                      style: const TextStyle(
                                        color: Color(0xffef4444),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' wrong',
                                      style: TextStyle(
                                        color: Color(0xff9ca3af),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Type this number:',
                        style: TextStyle(
                          color: Color(0xff9ca3af),
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(
                            _shakeOffset(_shakeController.value),
                            0,
                          ),
                          child: child,
                        ),
                        child: Text(
                          '$_targetNumber',
                          style: TextStyle(
                            color: _wrongAnimation
                                ? const Color(0xffef4444)
                                : Colors.white,
                            fontSize: 128,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: SizedBox(
                          width: 256,
                          height: 8,
                          child: Stack(
                            children: [
                              ColoredBox(color: Colors.white.withAlpha(26)),
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xff3b82f6),
                                        Color(0xff22c55e),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                NumberPad(
                  hintNumber: _hintNumber,
                  showDelete: false,
                  deleteEnabled: false,
                  onNumberPressed: _handleNumber,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          if (_pressedNumber != null)
            PressedNumberOverlay(number: _pressedNumber!),
        ],
      ),
    );
  }
}

class SpeedRunResultsScreen extends StatelessWidget {
  const SpeedRunResultsScreen({
    super.key,
    required this.totalNumbers,
    required this.wrongAttempts,
    required this.elapsedMilliseconds,
  });

  final int totalNumbers;
  final int wrongAttempts;
  final int elapsedMilliseconds;

  @override
  Widget build(BuildContext context) {
    final rawSeconds = elapsedMilliseconds / 1000;
    final penalty = wrongAttempts * 2;
    final finalSeconds = rawSeconds + penalty;

    return _BlackGameScaffold(
      child: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 80,
                        color: Color(0xfffacc15),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Finished!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Great job completing all numbers!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff9ca3af),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(13),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withAlpha(26)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _ResultStatRow(
                                label: 'Numbers Typed:',
                                value: '$totalNumbers',
                              ),
                              _ResultStatRow(
                                label: 'Wrong Attempts:',
                                value: '$wrongAttempts',
                                valueColor: const Color(0xffef4444),
                              ),
                              _ResultStatRow(
                                label: 'Raw Time:',
                                value: '${rawSeconds.toStringAsFixed(2)}s',
                              ),
                              _ResultStatRow(
                                label: 'Time Penalty:',
                                value: '+${penalty}s',
                                valueColor: const Color(0xffef4444),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Final Time:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${finalSeconds.toStringAsFixed(2)}s',
                                      style: const TextStyle(
                                        color: Color(0xff22c55e),
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xff2563eb),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Back to Settings'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const CelebrationOverlay(particleCount: 150),
        ],
      ),
    );
  }
}

class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.hintNumber,
    required this.showDelete,
    required this.deleteEnabled,
    required this.onNumberPressed,
    this.onDelete,
    this.disabled = false,
  });

  final int? hintNumber;
  final bool showDelete;
  final bool deleteEnabled;
  final bool disabled;
  final ValueChanged<int> onNumberPressed;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (final number in [1, 2, 3, 4, 5, 6, 7, 8, 9])
        NumberButton(
          number: number,
          isHinted: hintNumber == number,
          disabled: disabled,
          onPressed: () => onNumberPressed(number),
        ),
      const SizedBox.square(dimension: 80),
      NumberButton(
        number: 0,
        isHinted: hintNumber == 0,
        disabled: disabled,
        onPressed: () => onNumberPressed(0),
      ),
      if (showDelete)
        IconButton(
          onPressed: deleteEnabled ? onDelete : null,
          icon: const Icon(Icons.backspace_outlined, size: 28),
          color: Colors.white,
          disabledColor: Colors.white.withAlpha(77),
          style: IconButton.styleFrom(
            fixedSize: const Size.square(80),
            shape: const CircleBorder(),
          ),
        )
      else
        const SizedBox.square(dimension: 80),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Wrap(spacing: 16, runSpacing: 16, children: items),
      ),
    );
  }
}

class NumberButton extends StatefulWidget {
  const NumberButton({
    super.key,
    required this.number,
    required this.isHinted,
    required this.disabled,
    required this.onPressed,
  });

  final int number;
  final bool isHinted;
  final bool disabled;
  final VoidCallback onPressed;

  @override
  State<NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<NumberButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void didUpdateWidget(covariant NumberButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHinted && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isHinted && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = widget.isHinted
            ? 0.35 + (_pulseController.value * 0.25)
            : 0.0;
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: widget.isHinted
                ? [
                    BoxShadow(
                      color: const Color(0xfffacc15).withValues(alpha: glow),
                      blurRadius: 26,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: SizedBox.square(
        dimension: 80,
        child: OutlinedButton(
          onPressed: widget.disabled ? null : widget.onPressed,
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.white),
            side: WidgetStateProperty.all(
              BorderSide(
                color: widget.isHinted
                    ? const Color(0xfffacc15)
                    : Colors.white.withAlpha(77),
                width: 2,
              ),
            ),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (widget.isHinted) {
                return const Color(0xfffacc15).withAlpha(77);
              }
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withAlpha(64);
              }
              return Colors.white.withAlpha(13);
            }),
            shape: WidgetStateProperty.all(const CircleBorder()),
            textStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 36, fontWeight: FontWeight.w300),
            ),
          ),
          child: Text('${widget.number}'),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: 'Number ${widget.number}',
      child: Opacity(opacity: widget.disabled ? 0.5 : 1, child: button),
    );
  }
}

class PasscodeDots extends StatelessWidget {
  const PasscodeDots({super.key, required this.count, required this.filled});

  final int count;
  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isFilled = index < filled;
        return AnimatedScale(
          scale: isFilled ? 1.1 : 1,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 16,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? Colors.white : Colors.transparent,
              border: Border.all(
                color: Colors.white.withAlpha(isFilled ? 255 : 102),
                width: 2,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class PressedNumberOverlay extends StatelessWidget {
  const PressedNumberOverlay({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            final scale = value < 0.5
                ? 0.8 + value * 0.6
                : 1.1 - (value - 0.5) * 0.2;
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 - value * 30),
                child: Transform.scale(scale: scale, child: child),
              ),
            );
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(128),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 60,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({super.key, required this.particleCount});

  final int particleCount;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _particles = List.generate(widget.particleCount, (_) {
      return _ConfettiParticle(
        angle: -pi + random.nextDouble() * pi,
        distance: 120 + random.nextDouble() * 260,
        color: Colors.primaries[random.nextInt(Colors.primaries.length)],
        size: 6 + random.nextDouble() * 8,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ConfettiPainter(
              particles: _particles,
              progress: Curves.easeOut.transform(_controller.value),
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.angle,
    required this.distance,
    required this.color,
    required this.size,
  });

  final double angle;
  final double distance;
  final Color color;
  final double size;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.6);
    for (final particle in particles) {
      final offset = Offset(
        cos(particle.angle) * particle.distance * progress,
        sin(particle.angle) * particle.distance * progress + 180 * progress,
      );
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1 - progress.clamp(0, 1));
      canvas.save();
      canvas.translate(origin.dx + offset.dx, origin.dy + offset.dy);
      canvas.rotate(progress * pi * 2);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _BlackGameScaffold extends StatelessWidget {
  const _BlackGameScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: child);
  }
}

class _FeedbackText extends StatelessWidget {
  const _FeedbackText({required this.feedback});

  final FeedbackState? feedback;

  @override
  Widget build(BuildContext context) {
    final text = switch (feedback) {
      FeedbackState.success => 'Correct! Great job!',
      FeedbackState.error => 'Try again!',
      null => '',
    };
    final color = switch (feedback) {
      FeedbackState.success => const Color(0xff22c55e),
      FeedbackState.error => const Color(0xffef4444),
      null => Colors.transparent,
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.4),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Text(
        text,
        key: ValueKey(text),
        style: TextStyle(color: color, fontSize: 14),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xff030213),
          backgroundColor: selected
              ? const Color(0xff030213).withAlpha(13)
              : Colors.transparent,
          side: BorderSide(
            color: selected
                ? const Color(0xff030213)
                : Colors.black.withAlpha(26),
            width: 2,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            subtitle,
            style: const TextStyle(color: Color(0xff717182), fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _TopStat extends StatelessWidget {
  const _TopStat({
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        child,
      ],
    );
  }
}

class _ResultStatRow extends StatelessWidget {
  const _ResultStatRow({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withAlpha(26))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xff9ca3af), fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

double _shakeOffset(double value) {
  if (value == 0 || value == 1) {
    return 0;
  }
  return sin(value * pi * 10) * 8;
}

String formatStopwatch(int milliseconds) {
  final minutes = milliseconds ~/ 60000;
  final seconds = (milliseconds ~/ 1000) % 60;
  final centiseconds = (milliseconds ~/ 10) % 100;
  return '$minutes:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}';
}

part of 'package:pinpal/main.dart';

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
  int? _hintNumber;
  Timer? _hintTimer;
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
          if (_feedback == FeedbackState.success)
            const CelebrationOverlay(particleCount: 100),
        ],
      ),
    );
  }
}

part of 'package:pinpal/main.dart';

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
  int? _hintNumber;
  Timer? _speedTimer;
  Timer? _hintTimer;
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
        ],
      ),
    );
  }
}

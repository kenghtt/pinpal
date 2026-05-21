part of 'package:pinpal/main.dart';

class SpeedRunScreen extends StatefulWidget {
  const SpeedRunScreen({
    super.key,
    required this.settings,
    required this.highScore,
    required this.onUpdateHighScore,
  });

  final GameSettings settings;
  final int highScore;
  final ValueChanged<int> onUpdateHighScore;

  @override
  State<SpeedRunScreen> createState() => _SpeedRunScreenState();
}

class _SpeedRunScreenState extends State<SpeedRunScreen>
    with TickerProviderStateMixin {
  final Random _random = Random();
  late final AnimationController _shakeController;
  late List<int> _numberQueue;
  int _completed = 0;
  int _wrongAttempts = 0;
  int _elapsedMilliseconds = 0;
  bool _timerStarted = false;
  bool _wrongAnimation = false;
  bool _slideAnimation = false;
  int? _hintNumber;
  Timer? _speedTimer;
  Timer? _hintTimer;
  Timer? _wrongTimer;
  Timer? _queueTimer;
  DateTime? _startTime;

  int _nextTargetNumber({int? previous}) {
    final candidate = _random.nextInt(10);
    if (previous == null || candidate != previous) {
      return candidate;
    }
    return (candidate + 1 + _random.nextInt(9)) % 10;
  }

  List<int> _buildInitialQueue() {
    final queue = <int>[];
    for (var index = 0; index < 4; index++) {
      queue.add(_nextTargetNumber(previous: queue.isEmpty ? null : queue.last));
    }
    return queue;
  }

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _numberQueue = _buildInitialQueue();
    _restartHintTimer();
  }

  @override
  void dispose() {
    _speedTimer?.cancel();
    _hintTimer?.cancel();
    _wrongTimer?.cancel();
    _queueTimer?.cancel();
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
        setState(() => _hintNumber = _currentTargetNumber);
      }
    });
  }

  int? get _currentTargetNumber =>
      _numberQueue.isEmpty ? null : _numberQueue.first;

  void _handleNumber(int number) {
    final currentTargetNumber = _currentTargetNumber;
    if (_slideAnimation || currentTargetNumber == null) {
      return;
    }

    _startTimerIfNeeded();
    if (widget.settings.hapticFeedback) {
      HapticFeedback.selectionClick();
    }
    _restartHintTimer();

    if (number == currentTargetNumber) {
      final nextCompleted = _completed + 1;
      if (nextCompleted == widget.settings.speedRunCount) {
        _speedTimer?.cancel();
        final finalMilliseconds = _elapsedMilliseconds + _wrongAttempts * 2000;
        widget.onUpdateHighScore(finalMilliseconds);
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
        _slideAnimation = true;
      });
      _queueTimer?.cancel();
      _queueTimer = Timer(const Duration(milliseconds: 200), () {
        if (!mounted) {
          return;
        }
        setState(() {
          final previous = _numberQueue.isEmpty ? null : _numberQueue.last;
          _numberQueue = [
            ..._numberQueue.skip(1),
            _nextTargetNumber(previous: previous),
          ];
          _slideAnimation = false;
        });
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
                GameHeader(
                  leadingLabel: 'Home',
                  onBack: () => Navigator.of(context).pop(),
                  center: Row(
                    mainAxisSize: MainAxisSize.min,
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_rounded, color: Color(0xfffacc15)),
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
                      if (widget.highScore > 0) ...[
                        const SizedBox(width: 16),
                        BestScoreLabel(
                          value: formatStopwatch(widget.highScore),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Type these numbers:',
                        style: TextStyle(
                          color: Color(0xff9ca3af),
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedBuilder(
                        animation: _shakeController,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(
                            _shakeOffset(_shakeController.value),
                            0,
                          ),
                          child: child,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 180),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 24,
                              children: _numberQueue.indexed
                                  .map(
                                    (entry) => _QueueNumber(
                                      number: entry.$2,
                                      index: entry.$1,
                                      slideAnimation: _slideAnimation,
                                      wrongAnimation: _wrongAnimation,
                                    ),
                                  )
                                  .toList(),
                            ),
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

class _QueueNumber extends StatelessWidget {
  const _QueueNumber({
    required this.number,
    required this.index,
    required this.slideAnimation,
    required this.wrongAnimation,
  });

  final int number;
  final int index;
  final bool slideAnimation;
  final bool wrongAnimation;

  @override
  Widget build(BuildContext context) {
    final isCurrent = index == 0;
    final fontSize = switch (index) {
      0 => 144.0,
      1 => 80.0,
      _ => 50.0,
    };
    final opacity = switch (index) {
      0 => slideAnimation ? 0.0 : 1.0,
      1 => 0.7,
      _ => 0.4,
    };

    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedScale(
        scale: isCurrent && slideAnimation ? 0.95 : 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Text(
          '$number',
          style: TextStyle(
            color: isCurrent && wrongAnimation
                ? const Color(0xffef4444)
                : Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}

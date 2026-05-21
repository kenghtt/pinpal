part of 'package:pinpal/main.dart';

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withAlpha(51),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class _HomeActionButton extends StatelessWidget {
  const _HomeActionButton({
    required this.icon,
    required this.label,
    required this.primary,
    this.gradientColors,
    this.foregroundColor,
    this.borderColor,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool primary;
  final List<Color>? gradientColors;
  final Color? foregroundColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(primary ? 24 : 12);
    final textColor =
        foregroundColor ?? (primary ? const Color(0xff9333ea) : Colors.white);
    final fontWeight = primary ? FontWeight.w800 : FontWeight.w700;
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(height: primary ? 104 : 88),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: primary ? Colors.white : null,
                gradient: primary
                    ? null
                    : LinearGradient(
                        colors:
                            gradientColors ??
                            const [Color(0xfffacc15), Color(0xfffb923c)],
                      ),
                borderRadius: radius,
                border: primary
                    ? null
                    : Border.all(
                        color: borderColor ?? Colors.white24,
                        width: 2,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(primary ? 77 : 51),
                    blurRadius: primary ? 20 : 8,
                    offset: Offset(0, primary ? 10 : 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: radius,
                  onTap: onPressed,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: primary ? 32 : 18,
                      horizontal: primary ? 24 : 16,
                    ),
                    child: primary
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(icon, size: 40, color: textColor),
                              const SizedBox(width: 16),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 30,
                                      fontWeight: fontWeight,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, size: 24, color: textColor),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: fontWeight,
                                    height: 1,
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
        ],
      ),
    );
  }
}

class _FloatingNumbers extends StatelessWidget {
  const _FloatingNumbers();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          _FloatingNumber(
            number: '1',
            left: 40,
            top: 80,
            fontSize: 128,
            yOffset: -20,
            rotation: 0.09,
            duration: Duration(seconds: 6),
          ),
          _FloatingNumber(
            number: '5',
            right: 64,
            top: 160,
            fontSize: 112,
            yOffset: -30,
            rotation: -0.09,
            duration: Duration(seconds: 5),
          ),
          _FloatingNumber(
            number: '3',
            left: 80,
            bottom: 128,
            fontSize: 144,
            yOffset: -40,
            rotation: 0.05,
            duration: Duration(seconds: 4),
          ),
          _FloatingNumber(
            number: '7',
            right: 48,
            bottom: 192,
            fontSize: 96,
            yOffset: -20,
            rotation: 0.09,
            duration: Duration(seconds: 6),
          ),
          _FloatingNumber(
            number: '9',
            right: 96,
            top: 280,
            fontSize: 128,
            yOffset: -30,
            rotation: -0.09,
            duration: Duration(seconds: 5),
          ),
        ],
      ),
    );
  }
}

class _FloatingNumber extends StatefulWidget {
  const _FloatingNumber({
    required this.number,
    required this.fontSize,
    required this.yOffset,
    required this.rotation,
    required this.duration,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  final String number;
  final double fontSize;
  final double yOffset;
  final double rotation;
  final Duration duration;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  @override
  State<_FloatingNumber> createState() => _FloatingNumberState();
}

class _FloatingNumberState extends State<_FloatingNumber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      right: widget.right,
      bottom: widget.bottom,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final curved = Curves.easeInOut.transform(_controller.value);
          return Opacity(
            opacity: 0.2,
            child: Transform.translate(
              offset: Offset(0, widget.yOffset * curved),
              child: Transform.rotate(
                angle: widget.rotation * curved,
                child: child,
              ),
            ),
          );
        },
        child: Text(
          widget.number,
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff111827),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _ModernFieldLabel extends StatelessWidget {
  const _ModernFieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff374151),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

InputDecoration _settingsInputDecoration({
  String? hintText,
  String? counterText,
}) {
  return InputDecoration(
    hintText: hintText,
    counterText: counterText,
    filled: true,
    fillColor: const Color(0xfff9fafb),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xffe5e7eb)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xffa855f7), width: 2),
    ),
  );
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xff374151),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          _SettingsSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _FeatureToggleRow extends StatelessWidget {
  const _FeatureToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xff111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Color(0xff6b7280), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _SettingsSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GameSettingsStore _store = GameSettingsStore();
  final HighScoreStore _highScoreStore = HighScoreStore();
  GameSettings _settings = GameSettings.defaults;
  HighScores _highScores = HighScores.defaults;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadHighScores();
  }

  Future<void> _loadSettings() async {
    final settings = await _store.load();
    if (mounted) {
      setState(() => _settings = settings);
    }
  }

  Future<void> _loadHighScores() async {
    final highScores = await _highScoreStore.load();
    if (mounted) {
      setState(() => _highScores = highScores);
    }
  }

  Future<void> _updatePracticeHighScore(int score) async {
    final highScores = await _highScoreStore.updatePracticeHighScore(score);
    if (mounted) {
      setState(() => _highScores = highScores);
    }
  }

  Future<void> _updatePasscodeHeroHighScore(int score) async {
    final highScores = await _highScoreStore.updatePasscodeHeroHighScore(score);
    if (mounted) {
      setState(() => _highScores = highScores);
    }
  }

  Future<void> _updateSpeedRunHighScore(int count, int timeMs) async {
    final highScores = await _highScoreStore.updateSpeedRunHighScore(
      count,
      timeMs,
    );
    if (mounted) {
      setState(() => _highScores = highScores);
    }
  }

  Future<void> _openSettings() async {
    final saved = await Navigator.of(context).push<GameSettings>(
      MaterialPageRoute<GameSettings>(
        builder: (context) => SettingsScreen(initialSettings: _settings),
      ),
    );
    if (saved == null) {
      return;
    }
    await _store.save(saved);
    if (mounted) {
      setState(() => _settings = saved);
    }
  }

  void _openPractice() {
    final practiceSettings = _settings.copyWith(
      isRandomMode: true,
      passcodeLength: 1,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PracticeScreen(
          settings: practiceSettings,
          highScore: _highScores.practice,
          onUpdateHighScore: _updatePracticeHighScore,
        ),
      ),
    );
  }

  void _openPasscodeHero() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PracticeScreen(
          settings: _settings,
          highScore: _highScores.passcodeHero,
          onUpdateHighScore: _updatePasscodeHeroHighScore,
        ),
      ),
    );
  }

  void _openSpeedRun() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SpeedRunScreen(
          settings: _settings,
          highScore: _highScores.speedRunBestFor(_settings.speedRunCount),
          onUpdateHighScore: (timeMs) =>
              _updateSpeedRunHighScore(_settings.speedRunCount, timeMs),
        ),
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
            colors: [Color(0xff3b82f6), Color(0xffa855f7), Color(0xffec4899)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _FloatingNumbers()),
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 24,
                    right: 24,
                    child: _RoundIconButton(
                      icon: Icons.settings_rounded,
                      tooltip: 'Settings',
                      onPressed: _openSettings,
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 24,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 448),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              '🔢',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 112),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Number\nPractice',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 60,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    blurRadius: 24,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Let's learn numbers!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xe6ffffff),
                                fontSize: 24,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: _HomeActionButton(
                                icon: Icons.play_arrow_rounded,
                                label: "Let's Practice!",
                                primary: true,
                                onPressed: _openPractice,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _HomeActionButton(
                                    icon: Icons.shield_rounded,
                                    label: 'Passcode Hero',
                                    primary: false,
                                    gradientColors: const [
                                      Color(0xff3b82f6),
                                      Color(0xff22d3ee),
                                    ],
                                    borderColor: const Color(0x803b82f6),
                                    onPressed: _openPasscodeHero,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _HomeActionButton(
                                    icon: Icons.bolt_rounded,
                                    label: 'Speed Run',
                                    primary: false,
                                    gradientColors: const [
                                      Color(0xfffacc15),
                                      Color(0xfffb923c),
                                    ],
                                    foregroundColor: const Color(0xff713f12),
                                    borderColor: const Color(0x80f59e0b),
                                    // badge: '⚡',
                                    onPressed: _openSpeedRun,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

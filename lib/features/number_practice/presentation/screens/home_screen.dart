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
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(primary ? 24 : 16);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: primary ? Colors.white : null,
            gradient: primary
                ? null
                : const LinearGradient(
                    colors: [Color(0xfffacc15), Color(0xfffb923c)],
                  ),
            borderRadius: radius,
            border: primary
                ? null
                : Border.all(color: const Color(0x80eab308), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(primary ? 64 : 38),
                blurRadius: primary ? 32 : 18,
                offset: const Offset(0, 12),
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
                  vertical: primary ? 32 : 20,
                  horizontal: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: primary ? 40 : 28,
                      color: primary
                          ? const Color(0xff9333ea)
                          : const Color(0xff78350f),
                    ),
                    SizedBox(width: primary ? 16 : 12),
                    Text(
                      label,
                      style: TextStyle(
                        color: primary
                            ? const Color(0xff9333ea)
                            : const Color(0xff78350f),
                        fontSize: primary ? 30 : 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!primary)
          Positioned(
            top: -8,
            right: -8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xfffacc15),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  '⚡ BONUS1',
                  style: TextStyle(
                    color: Color(0xff78350f),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
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
  GameSettings _settings = GameSettings.defaults;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _store.load();
    if (mounted) {
      setState(() => _settings = settings);
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PracticeScreen(settings: _settings),
      ),
    );
  }

  void _openSpeedRun() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SpeedRunScreen(settings: _settings),
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
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔢', style: TextStyle(fontSize: 112)),
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
                            _HomeActionButton(
                              icon: Icons.play_arrow_rounded,
                              label: "Let's Practice!",
                              primary: true,
                              onPressed: _openPractice,
                            ),
                            const SizedBox(height: 16),
                            _HomeActionButton(
                              icon: Icons.bolt_rounded,
                              label: 'Speed Challenge',
                              primary: false,
                              onPressed: _openSpeedRun,
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

part of 'package:pinpal/main.dart';

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

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: value ? const Color(0xff9333ea) : const Color(0xffd1d5db),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
          ),
        ),
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

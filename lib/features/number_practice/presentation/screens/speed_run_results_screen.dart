part of 'package:pinpal/main.dart';

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

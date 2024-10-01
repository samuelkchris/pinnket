import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:hive/hive.dart';


class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  final List<FeatureHighlight> _highlights = [];
  int _currentIndex = 0;
  OverlayEntry? _currentOverlay;
  late Box<dynamic> _onboardingBox;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      _onboardingBox = await Hive.openBox('onboarding');
      _isInitialized = true;
    }
  }

  void addFeatureHighlight(FeatureHighlight highlight) {
    _highlights.add(highlight);
  }

  Future<void> startOnboarding(BuildContext context) async {
    await initialize();

    bool onboardingCompleted = await isOnboardingCompleted();
    if (onboardingCompleted) {
      return; // Don't start onboarding if it's already completed
    }

    _currentIndex = _onboardingBox.get('lastViewedStep', defaultValue: 0);

    if (_currentIndex >= _highlights.length) {
      // All steps have been viewed
      await _endOnboarding();
      return;
    }

    _showNextHighlight(context);
  }

  void _showNextHighlight(BuildContext context) {
    if (_currentIndex >= _highlights.length) {
      _endOnboarding();
      return;
    }

    _currentOverlay?.remove();
    final highlight = _highlights[_currentIndex];
    _currentOverlay = OverlayEntry(
      builder: (context) => FeatureHighlightOverlay(
        highlight: highlight,
        onNext: () {
          _currentIndex++;
          _saveProgress();
          _showNextHighlight(context);
        },
        onSkip: () => _endOnboarding(),
        totalSteps: _highlights.length,
        currentStep: _currentIndex + 1,
      ),
    );
    Overlay.of(context).insert(_currentOverlay!);
  }

  Future<void> _endOnboarding() async {
    _currentOverlay?.remove();
    _currentOverlay = null;
    await _saveProgress(completed: true);
  }

  Future<void> _saveProgress({bool completed = false}) async {
    await _onboardingBox.put('lastViewedStep', _currentIndex);
    await _onboardingBox.put('onboardingCompleted', completed);
  }

  Future<bool> isOnboardingCompleted() async {
    await initialize();
    return _onboardingBox.get('onboardingCompleted', defaultValue: false);
  }


}

class FeatureHighlight {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final IconData icon;

  FeatureHighlight({
    required this.targetKey,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class FeatureHighlightOverlay extends StatelessWidget {
  final FeatureHighlight highlight;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final int totalSteps;
  final int currentStep;

  const FeatureHighlightOverlay({
    super.key,
    required this.highlight,
    required this.onNext,
    required this.onSkip,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final targetBox = highlight.targetKey.currentContext?.findRenderObject() as RenderBox?;
    final targetPosition = targetBox?.localToGlobal(Offset.zero);
    final targetSize = targetBox?.size;

    if (targetPosition == null || targetSize == null) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final isOnLeftSide = targetPosition.dx < screenSize.width / 2;

    return Material(
      color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.4),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onNext,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: targetPosition.dx - 16,
            top: targetPosition.dy - 16,
            child: Container(
              width: targetSize.width + 32,
              height: targetSize.height + 32,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: targetPosition.dy + targetSize.height + 24,
            left: isOnLeftSide ? targetPosition.dx : null,
            right: isOnLeftSide ? null : screenSize.width - targetPosition.dx - targetSize.width,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(highlight.icon, color: Theme.of(context).colorScheme.primary, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              highlight.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        highlight.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$currentStep of $totalSteps',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: onSkip,
                                child: Text('Skip', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: onNext,
                                icon: const Icon(Iconsax.arrow_right_3, size: 18),
                                label: Text(currentStep == totalSteps ? 'Finish' : 'Next'),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
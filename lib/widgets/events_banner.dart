import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:intl/intl.dart';
import 'package:pinnket/providers/selectedevent_provider.dart';
import 'package:pinnket/widgets/share_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/event_provider.dart';
import '../models/event_models.dart';
import '../providers/selectedzone_provider.dart';

class AnimatedEventsBanner extends StatefulWidget {
  const AnimatedEventsBanner({super.key});

  @override
  _AnimatedEventsBannerState createState() => _AnimatedEventsBannerState();
}

class _AnimatedEventsBannerState extends State<AnimatedEventsBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentEventIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ticketSelectionProvider =
          Provider.of<TicketSelectionProvider>(context, listen: false);
      ticketSelectionProvider.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<double> _calculateAdScores(List<Event> events) {
    List<double> scores = [];
    for (var event in events) {
      double baseScore = 1.0;

      baseScore *= (1 + (event.likes ?? 0) / 100);
      final newEventDate = DateTime.parse(event.eventDate!);

      Duration timeUntilEvent = newEventDate.difference(DateTime.now());
      int daysUntilEvent = timeUntilEvent.inDays;
      if (daysUntilEvent <= 7) {
        baseScore *= 1.5;
      } else if (daysUntilEvent <= 30) {
        baseScore *= 1.2;
      }

      int availableTickets = event.eventZones?.first.maxtickets ?? 0;
      if (availableTickets < 100) {
        baseScore *= 1.3;
      }

      scores.add(baseScore);
    }
    return scores;
  }

  int _selectNextEventIndex(List<double> adScores) {
    double totalScore = adScores.reduce((a, b) => a + b);
    double randomValue = Random().nextDouble() * totalScore;
    double cumulativeScore = 0;

    for (int i = 0; i < adScores.length; i++) {
      cumulativeScore += adScores[i];
      if (randomValue <= cumulativeScore) {
        return i;
      }
    }

    return adScores.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final upcomingEvents = eventProvider.getUpcomingEvents();

        if (upcomingEvents.isEmpty) {
          return _buildShimmerBanner(context);
        }

        final adScores = _calculateAdScores(upcomingEvents);
        _currentEventIndex = _selectNextEventIndex(adScores);
        final currentEvent = upcomingEvents[_currentEventIndex];

        return _buildEventBanner(context, currentEvent);
      },
    );
  }

  Widget _buildShimmerBanner(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final double height = isSmallScreen ? 250 : 350;
        final double horizontalPadding = isSmallScreen ? 16 : 30;
        final double verticalPadding = isSmallScreen ? 16 : 24;

        return Container(
          height: height,
          margin: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: verticalPadding),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventBanner(BuildContext context, Event currentEvent) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final double height = isSmallScreen ? 300 : 350;
        final double horizontalPadding = isSmallScreen ? 0 : 30;
        final double verticalPadding = isSmallScreen ? 0 : 24;

        return Container(
          height: height,
          margin: EdgeInsets.symmetric(
              horizontal: horizontalPadding, vertical: verticalPadding),
          child: isSmallScreen
              ? _buildMobileBanner(context, currentEvent, theme)
              : _buildDesktopBanner(context, currentEvent, theme),
        );
      },
    );
  }

  Widget _buildMobileBanner(
      BuildContext context, Event currentEvent, ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: Image.network(
            currentEvent.bannerURL ?? 'https://picsum.photos/800/400?random=1',
            fit: BoxFit.cover,
            width: double.infinity,
            filterQuality: FilterQuality.high,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentEvent.name!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    theme,
                    Iconsax.calendar,
                    DateFormat('MMM dd, yyyy')
                        .format(DateTime.parse(currentEvent.eventDate!))
                        .toString(),
                  ),
                  _buildInfoChip(
                      theme, Iconsax.location, currentEvent.location ?? 'TBA'),
                ],
              ),
              const SizedBox(height: 16),
              _buildMobileButtons(theme, currentEvent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopBanner(
      BuildContext context, Event currentEvent, ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          BlurHash(
            hash: "L5H2EC=PM+er4wede3yy${UniqueKey()}",
            image: currentEvent.bannerURL ??
                'https://picsum.photos/800/400?random=1',
            imageFit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(
                          theme,
                          Iconsax.calendar,
                          DateFormat('MMM dd, yyyy')
                              .format(DateTime.parse(currentEvent.eventDate!))
                              .toString(),
                        ),
                        _buildInfoChip(theme, Iconsax.location,
                            currentEvent.location ?? 'TBA'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildDesktopButton(theme, currentEvent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileButtons(ThemeData theme, Event event) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              precacheImage(NetworkImage(event.evLogo!), context);
              final selectedEventProvider =
                  Provider.of<SelectedEventProvider>(context, listen: false);
              selectedEventProvider.setSelectedEvent(event);

              // Navigate to the event details page
              context.go('/events/${event.eid}');
            },
            icon: const Icon(Iconsax.ticket, size: 16),
            label: const Text('Buy Tickets'),
            style: ElevatedButton.styleFrom(
              foregroundColor: theme.colorScheme.onPrimary,
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            _showSlidingShareDrawer(context, event);
          },
          icon: const Icon(Iconsax.share, size: 20),
          style: IconButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurfaceVariant,
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest.withOpacity(0.8),
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopButton(ThemeData theme, Event event) {
    return ElevatedButton.icon(
      onPressed: () {
        precacheImage(NetworkImage(event.evLogo!), context);
        final selectedEventProvider =
            Provider.of<SelectedEventProvider>(context, listen: false);
        selectedEventProvider.setSelectedEvent(event);

        // Navigate to the event details page
        context.go('/events/${event.eid}');
      },
      icon: const Icon(Iconsax.ticket, size: 18),
      label: const Text('Buy Tickets'),
      style: ElevatedButton.styleFrom(
        foregroundColor: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
    );
  }
}

void _showSlidingShareDrawer(BuildContext context, Event? event) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation secondaryAnimation) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: SlidingShareDrawer(
          eventImageUrl: event?.bannerURL ?? '',
          eventName: event?.name ?? 'Event',
          baseUrl: "https://pinnket.com/#/events/${event?.eid}",
          eventDescription: event?.eventdescription ?? 'Event Description',
        ),
      );
    },
  );
}

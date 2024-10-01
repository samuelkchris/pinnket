import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/event_models.dart';

class EventHighlights extends StatelessWidget {
  final Event events;
  const EventHighlights({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    if(events.highlights == null || events.highlights!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Highlights',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 16,
            children: events.highlights!.map((highlight) {
              return _buildHighlightChip(
                context,
                _getIconForHighlight(highlight),
                highlight,
              );
            }).toList()
                .animate(interval: 100.ms)
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightChip(
      BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForHighlight(String highlight) {
    switch (highlight.toLowerCase()) {
      case 'live performances':
        return Iconsax.music;
      case 'parking availability':
        return Iconsax.car;
      case 'food & drinks':
        return Iconsax.coffee;
      case 'merchandise stalls':
        return Iconsax.shop;
      case 'state-of-the-art sound':
        return Iconsax.volume_high;
      case 'dj sets':
        return Iconsax.cd;
      case 'accessibility features':
        return Icons.wheelchair_pickup_rounded;
      case 'after-party':
        return Icons.party_mode_rounded;
      case 'kid-friendly activities':
        return Iconsax.emoji_happy;
      case 'laser show':
        return Iconsax.flash;
      default:
        return Iconsax.star;
    }
  }
}
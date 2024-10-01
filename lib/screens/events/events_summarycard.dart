import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinnket/utils/layout.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:html' as html;

import '../../models/event_models.dart';
import '../../utils/giude_generator.dart';

class EventSummaryCard extends StatelessWidget {
  final Event? event;

  const EventSummaryCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    bool isLargeScreen = isDisplayDesktop(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Iconsax.info_circle,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Event Summary',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (event == null)
                _buildShimmerLayout(context, isLargeScreen)
              else if (isLargeScreen)
                _buildTwoColumnLayout(context)
              else
                _buildSingleColumnLayout(context),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Iconsax.document_download),
                label: const Text('Download Event Guide'),
                onPressed: event == null
                    ? null
                    : () {
                        EventGuidePdfGenerator.downloadEventGuidePdf(
                            event!, context);
                      },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLayout(BuildContext context, bool isLargeScreen) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: isLargeScreen
          ? _buildTwoColumnShimmer(context)
          : _buildSingleColumnShimmer(context),
    );
  }

  Widget _buildSingleColumnShimmer(BuildContext context) {
    return Column(
      children: List.generate(5, (index) => _buildShimmerItem(context)),
    );
  }

  Widget _buildTwoColumnShimmer(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: List.generate(3, (index) => _buildShimmerItem(context)),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: List.generate(2, (index) => _buildShimmerItem(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 100,
                  height: 14,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleColumnLayout(BuildContext context) {
    bool parkingAvailable =
        event?.highlights?.contains('Parking Availability') ?? false;
    return Column(
      children: [
        _buildSummaryItem(
            context, Iconsax.timer_1, 'Duration', _calculateDuration()),
        _buildSummaryItem(
            context, Iconsax.people, 'Expected Attendance', '5000+'),
        _buildSummaryItem(
            context, Iconsax.music, 'Event Category', _getMusicGenre()),
        _buildSummaryItem(context, Iconsax.profile_2user, 'Age Restriction',
            _getAgeRestriction()),
        _buildSummaryItem(context, Iconsax.car, 'Parking Available',
            parkingAvailable ? 'Yes (Paid)' : 'No'),
        _buildSummaryItem(context, Iconsax.refresh, 'Refund Policy',
            event?.refund == true ? 'Refundable' : 'No Refund'),
      ],
    );
  }

  Widget _buildTwoColumnLayout(BuildContext context) {
    bool parkingAvailable =
        event?.highlights?.contains('Parking Availability') ?? false;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildSummaryItem(
                  context, Iconsax.timer_1, 'Duration', _calculateDuration()),
              _buildSummaryItem(
                  context, Iconsax.people, 'Expected Attendance', '5000+'),
              _buildSummaryItem(
                  context, Iconsax.music, 'Event Category', _getMusicGenre()),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              _buildSummaryItem(context, Iconsax.profile_2user,
                  'Age Restriction', _getAgeRestriction()),
              _buildSummaryItem(
                  context, Iconsax.car, 'Parking Available', parkingAvailable
                      ? 'Yes (Paid)'
                      : 'No'),
              _buildSummaryItem(context, Iconsax.refresh, 'Refund Policy',
                  event?.refund == true ? 'Refundable' : 'No Refund'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                size: 24, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDuration() {
    if (event?.eventDate != null && event?.endtime != null) {
      try {
        final startDateTime = DateTime.parse(event!.eventDate!);
        final endDateTime = DateTime.parse(event!.endtime!);
        final duration = endDateTime.difference(startDateTime);

        if (duration.inDays > 0) {
          return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
        } else if (duration.inHours > 0) {
          return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
        } else if (duration.inMinutes > 0) {
          return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
        } else {
          return 'Less than a minute';
        }
      } catch (e) {
        print('Error calculating duration: $e');
      }
    }
    return 'Duration not available';
  }

  String _getMusicGenre() {
    return event?.eventSubCategory?.name ?? 'Genre not specified';
  }

  String _getAgeRestriction() {
    return event?.eventAgeCategory?.name ?? 'Not specified';
  }
}

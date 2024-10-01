import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pinnket/services/toast_service.dart';

import '../models/event_models.dart';
import '../utils/generate_share_image.dart';

class DonationCard extends StatelessWidget {
  final double goalAmount;
  final double raisedAmount;
  final int donorsCount;
  final String eventName;
  final String eid;
  final String evLogo;
  final Event? event;

  const DonationCard({
    super.key,
    required this.goalAmount,
    required this.raisedAmount,
    required this.donorsCount,
    required this.eventName,
    required this.eid,
    required this.evLogo,
    this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentRaised = (raisedAmount / goalAmount).clamp(0.0, 1.0);
    final NumberFormat currencyFormat = NumberFormat.currency(
        locale: 'en_US', symbol: 'UGX ', decimalDigits: 0);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help Support This Cause',
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 8,
              percent: percentRaised,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              progressColor: theme.colorScheme.primary,
              barRadius: const Radius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currencyFormat.format(raisedAmount),
                      style: theme.textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'raised of ${currencyFormat.format(goalAmount)} goal',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      donorsCount.toString(),
                      style: theme.textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    Text(
                      'donors',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToDonationPage(context),
                    icon: Icon(Iconsax.heart, size: 20, color: theme.colorScheme.surface),
                    label: Text('Donate Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.surface)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Share donation link',
                  onPressed: () => _shareDonationLink(context),
                  icon: Icon(Iconsax.share, color: theme.colorScheme.secondary),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDonationPage(BuildContext context) {
    final queryParams = {
      'eventName': eventName,
      'goalAmount': goalAmount.toString(),
      'raisedAmount': raisedAmount.toString(),
      'eid': eid,
      'evLogo': evLogo
    };
    context.go('/donate?${Uri(queryParameters: queryParams).query}');
  }

  void _shareDonationLink(BuildContext context) {
    final queryParams = {
      'eventName': eventName,
      'goalAmount': goalAmount.toString(),
      'raisedAmount': raisedAmount.toString(),
      'eid': eid,
      'evLogo': evLogo
    };
    final title = event?.name ?? 'Event';
    final eventUrl = 'https://pinnket.com/#/donate?${Uri(queryParameters: queryParams).query}';
    final bannerImageUrl =
        event?.evLogo ?? 'https://example.com/default-banner.jpg';

    final eventDate = DateTime.parse(event!.eventDate!);
    final isDonate = event?.acceptDonations ?? false;
    final eventCode = event?.eventNumber;
ToastManager().showInfoToast(context, 'Generating share image...');
    generateAndDownloadShareImage(
        context, title, eventUrl, bannerImageUrl, isDonate, eventCode!, isDonateOnly: true);
    ToastManager().showSuccessToast(context, 'Share image generated successfully');
  }
}
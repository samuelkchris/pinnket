import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../models/event_models.dart';
import '../../widgets/card_banner.dart';


class EventZoneCard extends StatelessWidget {
  final EventZone zone;
  final bool isSelected;
  final VoidCallback onTap;

  const EventZoneCard({
    super.key,
    required this.zone,
    required this.isSelected,
    required this.onTap,
  });

  bool get isEarlyBird {
    final now = DateTime.now();
    final ebStarts = zone.ebstarts != null
        ? DateTime.parse(zone.ebstarts!.replaceAll('Z', ''))
        : null;
    final ebEnds = zone.ebends != null
        ? DateTime.parse(zone.ebends!.replaceAll('Z', ''))
        : null;
    return ebStarts != null &&
        ebEnds != null &&
        now.isAfter(ebStarts) &&
        now.isBefore(ebEnds);
  }

  int get currentPrice =>
      isEarlyBird ? (zone.ebcost ?? zone.cost ?? 0) : (zone.cost ?? 0);

  int get availableTickets => max(0, (zone.maxtickets ?? 0) - (zone.sold ?? 0));


  bool get isSoldOut {
    if (zone.maxtickets == null) return false;
    return zone.sold ==
        zone.maxtickets || availableTickets == 0 ;
  }


  double get discountPercentage =>
      isEarlyBird && zone.cost != null && zone.ebcost != null
          ? ((zone.cost! - zone.ebcost!) / zone.cost!) * 100
          : 0;

  String get discountText => discountPercentage > 0 ? 'Early Bird' : '';

  String get ticketText => zone.visibleOnApp == false
      ? ''
      : "$availableTickets tickets";

  @override
  Widget build(BuildContext context) {
    return CardBanner(
      position: CardBannerPosition.TOPRIGHT,
      text: isEarlyBird ? 'Early Bird' : 'Standard',
      text2: "Available",
      isSoldOut: isSoldOut,
      child: GestureDetector(
        onTap: isSoldOut ? null : onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            zone.name ?? 'Unknown Zone',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSoldOut ? 'Sold Out' : ticketText,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: isSoldOut
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0)
                              .format(currentPrice),
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (!isSoldOut && discountPercentage > 0)
                          Text(
                            '${discountPercentage.toStringAsFixed(0)}% off',
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Iconsax.tick_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

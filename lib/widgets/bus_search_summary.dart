// File: lib/widgets/bus_search_summary.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class BusSearchSummary extends StatelessWidget {
  final String from;
  final String to;
  final DateTime date;
  final int passengers;
  final Function(String) onSortChanged;
  final VoidCallback onEditSearch;

  const BusSearchSummary({
    Key? key,
    required this.from,
    required this.to,
    required this.date,
    required this.passengers,
    required this.onSortChanged,
    required this.onEditSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRouteInfo(context),
          const SizedBox(height: 12),
          _buildTripInfo(context),
          const SizedBox(height: 12),
          _buildQuickFilters(context),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(Iconsax.location, color: theme.colorScheme.onPrimary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  from,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Iconsax.arrow_right_1, color: theme.colorScheme.onPrimary, size: 20),
        ),
        Expanded(
          child: Row(
            children: [
              Icon(Iconsax.location_add, color: theme.colorScheme.onPrimary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  to,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Iconsax.edit, color: theme.colorScheme.onPrimary, size: 20),
          onPressed: onEditSearch,
          tooltip: 'Edit Search',
        ),
      ],
    );
  }

  Widget _buildTripInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTripInfoItem(
          context,
          Iconsax.calendar,
          DateFormat('EEE, MMM d').format(date),
        ),
        _buildTripInfoItem(
          context,
          Iconsax.people,
          '$passengers ${passengers == 1 ? 'passenger' : 'passengers'}',
        ),
      ],
    );
  }

  Widget _buildTripInfoItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: theme.colorScheme.onPrimary, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary),
        ),
      ],
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickFilterChip(context, 'Cheapest', Iconsax.money),
        _buildQuickFilterChip(context, 'Fastest', Iconsax.timer_1),
        _buildQuickFilterChip(context, 'Best Rated', Iconsax.star1),
      ],
    );
  }

  Widget _buildQuickFilterChip(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
        ],
      ),
      backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.9),
      selectedColor: theme.colorScheme.primaryContainer,
      selected: false,
      onSelected: (bool selected) {
        onSortChanged(label);
      },
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BusResultCard extends StatelessWidget {
  final String companyName;
  final double rating;
  final int reviewCount;
  final double price;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final List<String> amenities;
  final List<String> boardingPoints;
  final List<String> droppingPoints;
  final String cancellationPolicy;
  final VoidCallback onTap;

  const BusResultCard({
    super.key,
    required this.companyName,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.amenities,
    required this.boardingPoints,
    required this.droppingPoints,
    required this.cancellationPolicy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(theme),
                  const SizedBox(height: 16),
                  _buildTimeInfoRow(theme),
                  const SizedBox(height: 16),
                  _buildAmenitiesRow(theme),
                ],
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  // Wide layout
                  return Row(
                    children: [
                      Expanded(
                        child: _buildExpandableSection(
                            theme, 'Boarding Points', boardingPoints, Iconsax.location),
                      ),
                      Expanded(
                        child: _buildExpandableSection(
                            theme, 'Dropping Points', droppingPoints, Iconsax.location_add),
                      ),
                      Expanded(
                        child: _buildCancellationPolicy(theme),
                      ),
                    ],
                  );
                } else {
                  // Narrow layout
                  return Column(
                    children: [
                      _buildExpandableSection(
                          theme, 'Boarding Points', boardingPoints, Iconsax.location),
                      _buildExpandableSection(
                          theme, 'Dropping Points', droppingPoints, Iconsax.location_add),
                      _buildCancellationPolicy(theme),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                companyName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Iconsax.star1,
                      color: theme.colorScheme.secondary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '($reviewCount reviews)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfoRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimeInfo(theme, 'Departure', departureTime, Iconsax.timer_start),
        Icon(Iconsax.arrow_right_1, color: theme.colorScheme.primary),
        _buildTimeInfo(theme, 'Arrival', arrivalTime, Iconsax.timer_pause),
        _buildTimeInfo(theme, 'Duration', duration, Iconsax.timer),
      ],
    );
  }

  Widget _buildTimeInfo(
      ThemeData theme, String label, String time, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.tertiary),
        const SizedBox(height: 4),
        Text(
          time,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesRow(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities
          .map((amenity) => _buildAmenityChip(theme, amenity))
          .toList(),
    );
  }

  Widget _buildAmenityChip(ThemeData theme, String amenity) {
    return Chip(
      avatar: Icon(_getAmenityIcon(amenity),
          size: 16, color: theme.colorScheme.onTertiaryContainer),
      label: Text(
        amenity,
        style: TextStyle(
            fontSize: 12, color: theme.colorScheme.onTertiaryContainer),
      ),
      backgroundColor: theme.colorScheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity) {
      case 'Wifi':
        return Iconsax.wifi;
      case 'AC':
        return Icons.ac_unit;
      case 'TV':
        return Iconsax.monitor;
      case 'Charging Port':
        return Iconsax.electricity;
      case 'First Aid Box':
        return Iconsax.health;
      case 'Hand Sanitizer':
        return Icons.wash;
      case 'CCTV':
        return Iconsax.security_safe;
      case 'Tissues':
        return Iconsax.box;
      case 'Water Bottle':
        return Iconsax.cup;
      case 'Blanket':
        return Iconsax.receipt_2;
      case 'Snacks':
        return Iconsax.cake;
      case 'Newspaper':
        return Iconsax.document;
      case 'Emergency Exit':
        return Iconsax.danger;
      case 'Reading Light':
        return Iconsax.lamp;
      case 'Fire Extinguisher':
        return Icons.emergency;
      default:
        return Iconsax.star;
    }
  }

  Widget _buildExpandableSection(
      ThemeData theme, String title, List<String> points, IconData icon) {
    return ExpansionTile(
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
      ),
      leading: Icon(icon, color: theme.colorScheme.primary),
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: points.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                ),
              ),
              title: Text(points[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCancellationPolicy(ThemeData theme) {
    return ExpansionTile(
      title: Text(
        'Cancellation Policy',
        style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
      ),
      leading: Icon(Iconsax.info_circle, color: theme.colorScheme.primary),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            cancellationPolicy,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
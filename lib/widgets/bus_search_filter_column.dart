// File: lib/widgets/bus_search_filter_column.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BusSearchFilterColumn extends StatefulWidget {
  final Function onFiltersApplied;
  final Function onFiltersReset;

  const BusSearchFilterColumn({
    Key? key,
    required this.onFiltersApplied,
    required this.onFiltersReset,
  }) : super(key: key);

  @override
  _BusSearchFilterColumnState createState() => _BusSearchFilterColumnState();
}

class _BusSearchFilterColumnState extends State<BusSearchFilterColumn> {
  RangeValues _priceRange = const RangeValues(0, 200);
  String? _departureTime;
  String _selectedBusType = 'All';
  List<String> _selectedLocations = [];

  final List<String> _amenities = [
    'Wifi', 'AC', 'TV', 'Charging Port', 'First Aid Box',
    'Hand Sanitizer', 'CCTV', 'Tissues', 'Water Bottle', 'Blanket',
    'Snacks', 'Newspaper', 'Emergency Exit', 'Reading Light', 'Fire Extinguisher'
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildSection('Price Range', Iconsax.money, _buildPriceRangeFilter()),
            _buildSection('Departure Time', Iconsax.timer_start, _buildDepartureTimeFilter()),
            _buildSection('Bus Type', Iconsax.bus, _buildBusTypeFilter()),
            _buildSection('Amenities', Iconsax.wifi, _buildAmenitiesFilter()),
            _buildSection('Boarding Points', Iconsax.location, _buildLocationFilter('Boarding')),
            _buildSection('Dropping Points', Iconsax.location_add, _buildLocationFilter('Dropping')),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Iconsax.filter),
                    label: const Text('Apply Filters'),
                    onPressed: () => widget.onFiltersApplied(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Iconsax.refresh),
                  label: const Text('Reset'),
                  onPressed: () => widget.onFiltersReset(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        content,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      children: [
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 200,
          divisions: 20,
          labels: RangeLabels(
            '\$${_priceRange.start.round()}',
            '\$${_priceRange.end.round()}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$${_priceRange.start.round()}', style: Theme.of(context).textTheme.bodyMedium),
            Text('\$${_priceRange.end.round()}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }

  Widget _buildDepartureTimeFilter() {
    return DropdownButtonFormField<String>(
      value: _departureTime,
      hint: const Text('Select departure time'),
      onChanged: (String? newValue) {
        setState(() {
          _departureTime = newValue;
        });
      },
      items: ['06:00', '09:00', '12:00', '15:00', '18:00', '21:00']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildBusTypeFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ['All', 'Seater', 'Sleeper', 'Semi-Sleeper'].map((type) {
        return ChoiceChip(
          label: Text(type),
          selected: _selectedBusType == type,
          onSelected: (bool selected) {
            setState(() {
              _selectedBusType = selected ? type : 'All';
            });
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          labelStyle: TextStyle(
            color: _selectedBusType == type
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmenitiesFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ['Wi-Fi', 'AC', 'Restroom', 'USB Charging', 'Water Bottle', 'Blanket', 'Entertainment'].map((amenity) {
        return FilterChip(
          label: Text(amenity),
          selected: _amenities.contains(amenity),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _amenities.add(amenity);
              } else {
                _amenities.remove(amenity);
              }
            });
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: Theme.of(context).colorScheme.secondaryContainer,
          labelStyle: TextStyle(
            color: _amenities.contains(amenity)
                ? Theme.of(context).colorScheme.onSecondaryContainer
                : Theme.of(context).colorScheme.onSurface,
          ),
          avatar: Icon(
            _getAmenityIcon(amenity),
            size: 18,
            color: _amenities.contains(amenity)
                ? Theme.of(context).colorScheme.onSecondaryContainer
                : Theme.of(context).colorScheme.onSurface,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationFilter(String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search $type points',
            prefixIcon: const Icon(Iconsax.search_normal),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['Point A', 'Point B', 'Point C', 'Point D'].map((point) {
            return FilterChip(
              label: Text(point),
              selected: _selectedLocations.contains(point),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedLocations.add(point);
                  } else {
                    _selectedLocations.remove(point);
                  }
                });
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.tertiaryContainer,
              labelStyle: TextStyle(
                color: _selectedLocations.contains(point)
                    ? Theme.of(context).colorScheme.onTertiaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity) {
      case 'Wi-Fi':
        return Iconsax.wifi;
      case 'AC':
        return Iconsax.airdrop;
      case 'Restroom':
        return Iconsax.building_3;
      case 'USB Charging':
        return Iconsax.electricity;
      case 'Water Bottle':
        return Iconsax.cup;
      case 'Blanket':
        return Iconsax.refresh;
      case 'Entertainment':
        return Iconsax.monitor;
      default:
        return Iconsax.star;
    }
  }
}
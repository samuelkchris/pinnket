import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/bus_type.dart';
import '../app/main_screen.dart';

class BusDetailsAndSeatSelection extends StatefulWidget {
  final Bus bus;
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final double price;

  const BusDetailsAndSeatSelection({
    super.key,
    required this.bus,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
  });

  @override
  _BusDetailsAndSeatSelectionState createState() => _BusDetailsAndSeatSelectionState();
}

class _BusDetailsAndSeatSelectionState extends State<BusDetailsAndSeatSelection> {
  Set<int> selectedSeats = {};
  bool isRefundable = false;
  int selectedMealOption = 0;
  List<String> mealOptions = ['No meal', 'Vegetarian', 'Non-vegetarian', 'Vegan'];

  @override
  Widget build(BuildContext context) {
    return MainScreen(
      title: 'Select Seats',
      showSearchFAB: false,
      showFooter: false,
      bodySliver: [
        SliverToBoxAdapter(child: _buildBusDetails()),
        SliverToBoxAdapter(child: _buildSeatSelectionHeader()),
        SliverToBoxAdapter(child: _buildResponsiveLayout()),
      ],
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBusDetails() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(widget.bus.company, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
                _buildBusTypeChip(),
              ],
            ),
            const SizedBox(height: 16),
            _buildJourneyInfo(),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildBusTypeChip() {
    final color = _getBusTypeColor();
    return Chip(
      label: Text(
        widget.bus.type.toString().split('.').last.toUpperCase(),
        style: TextStyle(color: color.shade50, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color.shade100,
      side: BorderSide(color: color.shade300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  MaterialColor _getBusTypeColor() {
    switch (widget.bus.type) {
      case BusType.standard:
        return Colors.blue;
      case BusType.luxury:
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  Widget _buildJourneyInfo() {
    return Row(
      children: [
        Expanded(child: _buildLocationTime('From', widget.from, widget.departureTime)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Iconsax.arrow_right_3, color: Colors.grey, size: 32),
        ),
        Expanded(child: _buildLocationTime('To', widget.to, widget.arrivalTime, alignRight: true)),
      ],
    );
  }

  Widget _buildLocationTime(String label, String location, String time, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
        Text(location, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(time, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor)),
      ],
    );
  }

  Widget _buildSeatSelectionHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Your Seats', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildSeatLegend(),
        ],
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(Colors.grey.shade300, 'Available'),
        _buildLegendItem(Theme.of(context).colorScheme.primary, 'Selected'),
        _buildLegendItem(Colors.red.shade300, 'Booked'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildResponsiveLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildWideLayout();
        } else {
          return _buildNarrowLayout();
        }
      },
    );
  }

  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildLeftColumn(),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: _buildBusLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildLeftColumn(),
        const SizedBox(height: 16),
        _buildBusLayout(),
      ],
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTripDetails(),
        const SizedBox(height: 16),
        _buildAmenities(),
        const SizedBox(height: 16),
        _buildRefundableOption(),
        const SizedBox(height: 16),
        _buildMealSelection(),
        const SizedBox(height: 16),
        _buildBaggageInfo(),
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.3, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildTripDetails() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trip Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildTripDetailItem(Iconsax.calendar, 'Date', widget.departureTime.toString().split(' ')[0]),
            _buildTripDetailItem(Iconsax.clock, 'Duration', '6h 30m'),
            _buildTripDetailItem(Iconsax.location, 'Distance', '350 km'),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: TextStyle(color: Theme.of(context).primaryColor)),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amenities', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildAmenityChip(Iconsax.wifi, 'Wi-Fi'),
                _buildAmenityChip(Iconsax.devices, 'USB Charging'),
                _buildAmenityChip(Iconsax.menu_board, 'Entertainment'),
                _buildAmenityChip(Iconsax.box, 'AC'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Theme.of(context).primaryColor),
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: BorderSide(color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildRefundableOption() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: const Text('Refundable Ticket'),
        subtitle: const Text('Extra \$10 for refundable option'),
        value: isRefundable,
        onChanged: (bool value) {
          setState(() {
            isRefundable = value;
          });
        },
        secondary: Icon(Iconsax.shield_tick, color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildMealSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meal Preference', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Iconsax.cake),
              ),
              value: selectedMealOption,
              items: List.generate(mealOptions.length, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(mealOptions[index]),
                );
              }),
              onChanged: (int? value) {
                if (value != null) {
                  setState(() {
                    selectedMealOption = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaggageInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Baggage Allowance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildBaggageItem(Iconsax.bag, 'Carry-on', '1 x 7kg'),
            _buildBaggageItem(Iconsax.box, 'Check-in', '1 x 20kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildBaggageItem(IconData icon, String label, String allowance) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(allowance, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBusLayout() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildDriverSection(),
            const SizedBox(height: 20),
            ...widget.bus.seatLayout.map((row) => _buildSeatRow(row)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.3, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildDriverSection() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(40),
      ),
      child:  SvgPicture.asset('assets/icons/wheel.svg'),
    );
  }

  Widget _buildSeatRow(List<int> row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: row.map((seatNumber) {
          if (seatNumber == 0) {
            return const SizedBox(width: 50); // Aisle
          }
          return _buildSeat(seatNumber);
        }).toList(),
      ),
    );
  }

  Widget _buildSeat(int seatNumber) {
    final isSelected = selectedSeats.contains(seatNumber);
    final theme = Theme.of(context);
    final isBooked = seatNumber % 5 == 0; // Simulating some booked seats

    return GestureDetector(
      onTap: isBooked ? null : () => _toggleSeatSelection(seatNumber),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 45,
        height: 45,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isBooked
              ? Colors.red.shade300
              : (isSelected ? theme.colorScheme.primary : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: isSelected ? theme.colorScheme.primary.withOpacity(0.3) : Colors.transparent,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            seatNumber.toString(),
            style: TextStyle(
              color: isSelected || isBooked ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ).animate()
        .scale(duration: 300.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 300.ms);
  }

  void _toggleSeatSelection(int seatNumber) {
    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else {
        selectedSeats.add(seatNumber);
      }
    });
  }

  Widget _buildBottomBar() {
    final theme = Theme.of(context);
    double totalPrice = widget.price * selectedSeats.length;
    if (isRefundable) totalPrice += 10;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total: \$${totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${selectedSeats.length} ${selectedSeats.length == 1 ? 'seat' : 'seats'} selected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: selectedSeats.isNotEmpty
                  ? () => _navigateToBookingConfirmation(totalPrice)
                  : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary,
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Continue'),
                  SizedBox(width: 8),
                  Icon(Iconsax.arrow_right_3, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
  }

  void _navigateToBookingConfirmation(double totalPrice) {
    Map<String, dynamic> bookingDetails = {
      'bus': widget.bus,
      'from': widget.from,
      'to': widget.to,
      'departureTime': DateTime(2024, 3, 15, 10, 0), // Example date and time
      'arrivalTime': DateTime(2024, 3, 15, 16, 30), // Example date and time
      'price': totalPrice,
      'selectedSeats': selectedSeats.toList(),
      'isRefundable': isRefundable,
      'mealPreference': mealOptions[selectedMealOption],
      'passengers': 2, // Number of passengers
    };
    context.go('/booking-confirmation', extra: bookingDetails);
  }
}
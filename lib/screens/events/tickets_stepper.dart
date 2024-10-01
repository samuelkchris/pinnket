import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:pinnket/services/toast_service.dart';

import '../../models/event_models.dart';

import 'package:provider/provider.dart';

import '../../providers/selectedzone_provider.dart';
import 'event_zones.dart';

class TicketStepper extends StatefulWidget {
  final Event event;

  const TicketStepper({super.key, required this.event});

  @override
  _TicketStepperState createState() => _TicketStepperState();
}

class _TicketStepperState extends State<TicketStepper> {
  int currentStep = 0;
  late List<EventZone> ticketCategories;

  @override
  void initState() {
    super.initState();
    ticketCategories = widget.event.eventZones
            ?.where((zone) => zone.isactive == true && zone.cost != 0)
            .toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final eventEndDateTime = DateTime.parse(widget.event.endtime!);
    final isEnded = eventEndDateTime.isBefore(now);
    return Consumer<TicketSelectionProvider>(
      builder: (context, provider, child) {
        if (ticketCategories.isEmpty) {
          return Container();
        } else if (isEnded) {
          return Card(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                  children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 32),
                    Text(
                      'Event has ended',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 600.ms);
        } else {
          return Card(
            elevation: 8,
            shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                  children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 32),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCurrentStepContent(),
                    ),
                    const SizedBox(height: 32),
                    _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 600.ms);
        }
      },
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Container(
          width: 80,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index <= currentStep
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (currentStep) {
      case 0:
        return _buildCategorySelector();
      case 1:
        return _buildTicketCounter();
      case 2:
        return _buildConfirmation();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCategorySelector() {
    return Consumer<TicketSelectionProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Text(
              'Select Category',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              ticketCategories.length,
              (index) => EventZoneCard(
                zone: ticketCategories[index],
                isSelected:
                    provider.selectedZoneId == ticketCategories[index].zid,
                onTap: () {
                  provider.setSelectedZoneId(ticketCategories[index].zid!);
                  provider.setSelectedZoneName(ticketCategories[index].name!);
                  provider.setSelectedZone(ticketCategories[index]);
                  provider.setSelectedCategoryCost(
                      _calculateSingleTicketCost(ticketCategories[index]));
                },
              ),
            ),
          ],
        )
            .animate()
            .slideX(begin: -0.1, end: 0, duration: 300.ms)
            .fadeIn(duration: 300.ms);
      },
    );
  }

  int _calculateSingleTicketCost(EventZone zone) {
    final now = DateTime.now();
    final ebStarts =
        zone.ebstarts != null ? DateTime.parse(zone.ebstarts!) : null;
    final ebEnds = zone.ebends != null ? DateTime.parse(zone.ebends!) : null;
    final isEarlyBird = ebStarts != null &&
        ebEnds != null &&
        now.isAfter(ebStarts) &&
        now.isBefore(ebEnds);

    return isEarlyBird ? (zone.ebcost ?? zone.cost ?? 0) : (zone.cost ?? 0);
  }

  Widget _buildTicketCounter() {
    return Consumer<TicketSelectionProvider>(
      builder: (context, provider, child) {
        final selectedZone = provider.selectedZone;
        final maxTickets = selectedZone?.maxtickets ?? 10;
        return Column(
          children: [
            Text(
              'Number of Tickets',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.minus),
                    onPressed: () {
                      if (provider.ticketCount > 1) {
                        provider.setTicketCount(provider.ticketCount - 1);
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${provider.ticketCount}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Iconsax.add),
                    onPressed: () {
                      if (provider.ticketCount < maxTickets) {
                        provider.setTicketCount(provider.ticketCount + 1);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        )
            .animate()
            .slideX(begin: 0.1, end: 0, duration: 300.ms)
            .fadeIn(duration: 300.ms);
      },
    );
  }

  Widget _buildConfirmation() {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'UGX ', decimalDigits: 0);

    return Consumer<TicketSelectionProvider>(
      builder: (context, provider, child) {
        final selectedZone = provider.selectedZone;
        final totalCost =
            _calculateTotalCost(selectedZone!, provider.ticketCount);
        return Column(
          children: [
            Text(
              'Confirm Your Selection',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ConfirmationTile(
              label: 'Category',
              value: selectedZone.name ?? 'Unknown',
              icon: Iconsax.ticket,
            ),
            ConfirmationTile(
              label: 'Number of Tickets',
              value: '${provider.ticketCount}',
              icon: Iconsax.people,
            ),
            ConfirmationTile(
              label: 'Total',
              value:
                  currencyFormat.format(totalCost),
              icon: Iconsax.money,
              isTotal: true,
            ),
          ],
        )
            .animate()
            .slideX(begin: 0.1, end: 0, duration: 300.ms)
            .fadeIn(duration: 300.ms);
      },
    );
  }

  int _calculateTotalCost(EventZone zone, int ticketCount) {
    final now = DateTime.now();
    final ebStarts =
        zone.ebstarts != null ? DateTime.parse(zone.ebstarts!) : null;
    final ebEnds = zone.ebends != null ? DateTime.parse(zone.ebends!) : null;
    final isEarlyBird = ebStarts != null &&
        ebEnds != null &&
        now.isAfter(ebStarts) &&
        now.isBefore(ebEnds);

    final price =
        isEarlyBird ? (zone.ebcost ?? zone.cost ?? 0) : (zone.cost ?? 0);
    return price * ticketCount;
  }

  Widget _buildNavigationButtons() {
    return Consumer<TicketSelectionProvider>(
      builder: (context, provider, child) {
        bool isNextButtonEnabled =
            currentStep == 0 ? provider.selectedZone != null : true;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (currentStep > 0)
              CustomButton(
                icon: Iconsax.arrow_left,
                text: 'Back',
                onPressed: () => setState(() => currentStep--),
              )
            else
              const SizedBox(width: 100),
            CustomButton(
              icon: currentStep < 2 ? Iconsax.arrow_right : Iconsax.tick_circle,
              text: currentStep < 2 ? 'Next' : 'Confirm',
              onPressed: isNextButtonEnabled
                  ? () {
                      if (currentStep < 2) {
                        setState(() => currentStep++);
                      } else {
                        if (widget.event.onlineSale == true) {
                          context.go('/ticket-purchase/${widget.event.eid}');
                        } else {
                          ToastManager().showInfoToast(
                            context,
                            'Online sales are not available for this event, Tickets can only be purchased at the venue',
                          );
                        }
                      }
                    }
                  : () {
                      ToastManager().showInfoToast(
                        context,
                        'Please select a category',
                      );
                    },
            ),
          ],
        );
      },
    );
  }
}

class CategoryTile extends StatelessWidget {
  final EventZone category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: 'UGX ', decimalDigits: 0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.name ?? 'Unknown Category',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
            Text(
              'UGX ${currencyFormat.format(category.cost)}',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmationTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isTotal;

  const ConfirmationTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTotal
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isTotal
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Container(
            height: 20,
            width: 1,
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    ).animate().scale(duration: 200.ms);
  }
}

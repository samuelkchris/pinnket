import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinnket/models/ticket_download.dart';

class ModernTicketList extends StatelessWidget {
  final List<String> tickets;
  final TicketResponse? ticketInfor;
  final Function(String) onDownload;

  const ModernTicketList({
    super.key,
    required this.tickets,
    required this.onDownload,
    required this.ticketInfor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Tickets',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ).animate().fadeIn(duration: 600.ms).slideX(),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _TicketCard(
                ticket: ticket,
                onDownload: onDownload,
                index: index,
                ticketInfor: ticketInfor,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  final String ticket;
  final TicketResponse? ticketInfor;
  final Function(String) onDownload;
  final int index;

  const _TicketCard({
    super.key,
    required this.ticket,
    required this.onDownload,
    required this.index,
    required this.ticketInfor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticketInfor!.eventDetails.name!,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Purchased on: ${DateFormat('d MMMM, y').format(ticketInfor!.purchasedOn)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                      ),
                      Text(
                        'Ticket ID: $ticket',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Iconsax.document_download, size: 18),
                  label: const Text('Download'),
                  onPressed: () => onDownload(ticket),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (200 * index).ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }
}

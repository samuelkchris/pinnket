import 'package:flutter/material.dart';

class PaymentInstructionsPopover extends StatelessWidget {
  final String eventId;

  const PaymentInstructionsPopover({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment Instructions', style: theme.textTheme.titleLarge),
              IconButton(
                icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(context, '1',
              'A Payment prompt has been sent to the phone number provided.'),
          _buildInstructionStep(
              context, '2', 'Enter your MobileMoney PIN on your mobile phone.'),
          _buildInstructionStep(
              context, '3', 'PinnKET automatically receives your payment.'),
          _buildInstructionStep(context, '4',
              'Your tickets are generated and sent to phone/email.'),
          const Divider(height: 24),
          Text('OR',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Dial *217*413# and follow the prompts to pay for your ticket.'),
          const SizedBox(height: 16),
          Text('Event ID: $eventId',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(
      BuildContext context, String step, String instruction) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(instruction),
          ),
        ],
      ),
    );
  }
}

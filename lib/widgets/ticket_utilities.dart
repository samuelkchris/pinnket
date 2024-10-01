import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinnket/utils/layout.dart';
import 'package:pinnket/widgets/ticket_utiliycard.dart';

import 'animated_title.dart';

class TicketUtilities extends StatelessWidget {
  const TicketUtilities({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = isDisplayDesktop(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 48.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: isLargeScreen ? 48.0 : 24.0),
            child: const AnimatedTitle(title: 'Ticket Utilities'),
          ),
          SizedBox(height: isLargeScreen ? 32.0 : 24.0),
          isLargeScreen
              ? _buildLargeScreenUtilities(context)
              : _buildMobileUtilities(context),
        ],
      ),
    );
  }

  Widget _buildLargeScreenUtilities(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildModernUtilityCard(
              context,
              'Transfer Ticket',
              'Easily send your ticket to a friend or family member',
              Iconsax.send_2,
              Colors.blue,
              () => _showTransferTicket(context),
              isTransferring: true,
            ),
          ),
          const SizedBox(width: 24.0),
          Expanded(
            child: _buildModernUtilityCard(
              context,
              'Download Ticket',
              'Save your ticket offline for quick access anytime',
              Iconsax.document_download,
              Colors.green,
              () => _showDownloadTicket(context),
              isDownloading: true,
            ),
          ),
          const SizedBox(width: 24.0),
          Expanded(
            child: _buildModernUtilityCard(
              context,
              'Verify Ticket',
              'Ensure your ticket is valid and ready for use',
              Iconsax.verify,
              Colors.orange,
              () => _showVerifyTicket(context),
              isVerifying: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileUtilities(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMobileUtilityCard(
          context,
          'Transfer Ticket',
          'Send your ticket to a friend',
          Iconsax.send_2,
          Colors.blue,
          () => _showTransferTicket(context),
        ),
        const SizedBox(height: 12.0),
        _buildMobileUtilityCard(
          context,
          'Download Ticket',
          'Save your ticket offline',
          Iconsax.document_download,
          Colors.green,
          () => _showDownloadTicket(context),
        ),
        const SizedBox(height: 12.0),
        _buildMobileUtilityCard(
          context,
          'Verify Ticket',
          'Check if your ticket is valid',
          Iconsax.verify,
          Colors.orange,
          () => _showVerifyTicket(context),
        ),
      ],
    );
  }

  Widget _buildModernUtilityCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isDownloading = false,
    bool isTransferring = false,
    bool isVerifying = false,
  }) {
    return ModernUtilityCard(
      title: title,
      description: description,
      icon: icon,
      color: color,
      onTap: onTap,
      isDownloading: isDownloading,
      isTransferring: isTransferring,
      isVerifying: isVerifying,
    );
  }

  Widget _buildMobileUtilityCard(BuildContext context, String title,
      String description, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(

              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: color.withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(Iconsax.arrow_right_3, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransferTicket(BuildContext context) {
    context.go('/ticket-transfer');
  }

  void _showDownloadTicket(BuildContext context) {
    context.go('/ticket-download');
  }

  void _showVerifyTicket(BuildContext context) {
    context.go('/ticket-verification');
  }
}

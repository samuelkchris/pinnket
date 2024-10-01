import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/hider.dart';
import '../app/main_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String amount;
  final String eventName;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.eventName,
  });

  @override
  _PaymentSuccessScreenState createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    callJavaScriptMethods();
    _controller = AnimationController(vsync: this);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _confettiController.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLargeScreen = constraints.maxHeight > 700;
            return Stack(
              children: [
                _buildBackground(context),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          isLargeScreen ? 800 : constraints.maxWidth * 0.9,
                      maxHeight: isLargeScreen
                          ? constraints.maxHeight
                          : double.infinity,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: isLargeScreen ? 3 : 2,
                          child: _buildSuccessAnimation(isLargeScreen),
                        ),
                        _buildContentColumn(context, isLargeScreen),
                        const SizedBox(height: 20),
                        Flexible(
                          flex: 2,
                          child: _buildButtonsSection(context, isLargeScreen),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildConfetti(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation(bool isLargeScreen) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Lottie.network(
        'https://assets3.lottiefiles.com/packages/lf20_jbrw3hcz.json',
        controller: _controller,
        height: isLargeScreen ? 200 : 150,
        animate: true,
        onLoaded: (composition) {
          _controller
            ..duration = composition.duration
            ..forward();
        },
      ),
    );
  }

  Widget _buildContentColumn(BuildContext context, bool isLargeScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Congratulations!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontSize: isLargeScreen ? 24 : 20,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 13),
        Text(
          'Your ticket purchase was successful!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: isLargeScreen ? 18 : 16,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Get ready for an amazing experience.\nWe\'re excited to see you at the event!',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: isLargeScreen ? 16 : 14,
              ),
          textAlign: TextAlign.center,
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.2, end: 0),
        SizedBox(height: isLargeScreen ? 24 : 16),
        _buildPaymentDetails(context, isLargeScreen),
      ],
    )
        .animate(delay: 200.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildPaymentDetails(BuildContext context, bool isLargeScreen) {
    return Container(
      width: 600,
      decoration: const BoxDecoration(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: isLargeScreen ? 24 : 16,
        ),
        child: Column(
          children: [
            _buildDetailRow(
                context, 'Amount Paid', widget.amount, isLargeScreen),
            const Divider(height: 24),
            _buildDetailRow(context, 'Event', widget.eventName, isLargeScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, bool isLargeScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: isLargeScreen ? 16 : 14,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
                fontSize: isLargeScreen ? 18 : 16,
              ),
        ),
      ],
    );
  }

  Widget _buildButtonsSection(BuildContext context, bool isLargeScreen) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isLargeScreen ? 800 : 600,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: isLargeScreen ? 16 : 12,
        runSpacing: isLargeScreen ? 16 : 12,
        children: [
          _buildButton(
            context,
            'View My Ticket',
            Iconsax.ticket,
            () {
              // Navigate to ticket view
            },
            isLargeScreen,
            isPrimary: true,
          ),
          _buildButton(
            context,
            'Share Event',
            Iconsax.share,
            () {
              // Implement share functionality
            },
            isLargeScreen,
          ),
          _buildButton(
            context,
            'Return to Home',
            Iconsax.home,
            () {
              // Navigate to home screen
            },
            isLargeScreen,
          ),
        ],
      ),
    )
        .animate(delay: 200.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildButton(BuildContext context, String label, IconData icon,
      VoidCallback onPressed, bool isLargeScreen,
      {bool isPrimary = false}) {
    return SizedBox(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: TextStyle(fontSize: isLargeScreen ? 18 : 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          foregroundColor: isPrimary
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSecondary,
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 32 : 24,
            vertical: isLargeScreen ? 16 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: isPrimary ? 8 : 4,
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: pi / 2,
        maxBlastForce: 5,
        minBlastForce: 2,
        emissionFrequency: 0.05,
        numberOfParticles: 50,
        gravity: 0.05,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple
        ],
      ),
    );
  }
}

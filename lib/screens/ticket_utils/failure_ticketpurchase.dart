import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinnket/utils/hider.dart';
import 'package:wiredash/wiredash.dart';

class PaymentFailureScreen extends StatefulWidget {
  final VoidCallback onTryAgain;
  final String errorMessage;

  const PaymentFailureScreen({
    super.key,
    required this.onTryAgain,
    required this.errorMessage,
  });

  @override
  _PaymentFailureScreenState createState() => _PaymentFailureScreenState();
}

class _PaymentFailureScreenState extends State<PaymentFailureScreen> {
  @override
  void initState() {
    super.initState();
    callJavaScriptMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLargeScreen = constraints.maxHeight > 600;
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxWidth: constraints.maxWidth,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: isLargeScreen ? 150 : 120,
                      child: Lottie.network(
                        'https://assets9.lottiefiles.com/packages/lf20_qpwbiyxf.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Payment Failed',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isLargeScreen ? 10 : 8),
                          Text(
                            'We encountered an issue while processing your payment.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(),
                            textAlign: TextAlign.center,
                          ),
                          _buildCommonReasonsCard(context, isLargeScreen),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              widget.onTryAgain();
                            },
                            icon: const Icon(Iconsax.refresh, size: 24),
                            label: Text(
                              'Try Again',
                              style:
                                  TextStyle(fontSize: isLargeScreen ? 18 : 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isLargeScreen ? 32 : 24,
                                vertical: isLargeScreen ? 16 : 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          SizedBox(width: isLargeScreen ? 24 : 16),
                          TextButton.icon(
                            onPressed: () {
                              Wiredash.of(context)
                                  .show(inheritMaterialTheme: true);
                            },
                            icon: const Icon(Iconsax.support, size: 24),
                            label: Text(
                              'Contact Support',
                              style:
                                  TextStyle(fontSize: isLargeScreen ? 18 : 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCommonReasonsCard(BuildContext context, bool isLargeScreen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Common Reasons for Payment Failure:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 22 : 20,
                  ),
            ),
            SizedBox(height: isLargeScreen ? 16 : 12),
            _buildReasonItem(context, 'Insufficient funds in your account',
                Iconsax.empty_wallet),
            _buildReasonItem(
                context, 'Incorrect card information entered', Iconsax.card),
            _buildReasonItem(
                context, 'Your card has expired', Iconsax.card_remove),
            _buildReasonItem(context, 'Transaction exceeds your card limit',
                Iconsax.chart_square),
            _buildReasonItem(
                context,
                'Temporary hold or fraud prevention measure',
                Iconsax.security_safe),
            _buildReasonItem(
                context, 'Network or connectivity issue', Iconsax.wifi_square),
            SizedBox(height: isLargeScreen ? 16 : 12),
            Text(
              'Please check these potential issues and try your payment again. If the problem persists, please contact your bank or our support team for assistance.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonItem(BuildContext context, String reason, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reason,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

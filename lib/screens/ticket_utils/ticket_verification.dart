import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';

import '../../services/toast_service.dart';
import '../../services/ticket_verification_service.dart';
import '../../models/ticket_verification.dart';
import '../app/main_screen.dart';

class TicketVerificationScreen extends StatefulWidget {
  const TicketVerificationScreen({super.key});

  @override
  _TicketVerificationScreenState createState() =>
      _TicketVerificationScreenState();
}

class _TicketVerificationScreenState extends State<TicketVerificationScreen> {
  final TextEditingController _manualCodeController = TextEditingController();
  String scannedCode = '';
  bool isTicketScanning = true;
  final ToastManager _toastManager = ToastManager();
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  final TicketVerificationService _verificationService =
      TicketVerificationService();
  bool _isLoading = false;
  TicketVerificationResponse? _verificationResponse;

  @override
  Widget build(BuildContext context) {
    return MainScreen(
      showSearchFAB: false,
      bodySliver: [
        SliverLayoutBuilder(
          builder: (BuildContext context, SliverConstraints constraints) {
            final isLargeScreen = constraints.crossAxisExtent > 900;
            final isMediumScreen = constraints.crossAxisExtent > 600 &&
                constraints.crossAxisExtent <= 900;

            return SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 64 : (isMediumScreen ? 32 : 16),
                vertical: isLargeScreen ? 48 : (isMediumScreen ? 32 : 24),
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(isLargeScreen),
                  SizedBox(height: isLargeScreen ? 48 : 32),
                  if (isLargeScreen)
                    _buildLargeScreenLayout()
                  else
                    _buildSmallScreenLayout(isMediumScreen),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify Your Ticket or Pass',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ).animate().fadeIn(duration: 600.ms).slideX(),
        SizedBox(height: isLargeScreen ? 16 : 8),
        Text(
          'Scan a QR code or PDF417 barcode, or manually enter the code to verify your ticket or pass',
          style: Theme.of(context).textTheme.bodyLarge,
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(),
      ],
    );
  }

  Widget _buildLargeScreenLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildScanningArea(true)),
        const SizedBox(width: 32),
        Expanded(child: _buildManualEntry(true)),
      ],
    );
  }

  Widget _buildSmallScreenLayout(bool isMediumScreen) {
    return Column(
      children: [
        _buildScanningArea(isMediumScreen),
        SizedBox(height: isMediumScreen ? 32 : 24),
        _buildManualEntry(isMediumScreen),
      ],
    );
  }

  Widget _buildScanningArea(bool isLargeScreen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Scan Code',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: 600.ms).slideX(),
            SizedBox(height: isLargeScreen ? 24 : 16),
            _buildScanTypeSelector(),
            SizedBox(height: isLargeScreen ? 32 : 24),
            _buildScanButton(
                Iconsax.scan, 'Scan Code', _scanCode, isLargeScreen),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 800.ms).slideY();
  }

  Widget _buildScanButton(
      IconData icon, String label, VoidCallback onPressed, bool isLargeScreen) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(_isLoading ? 'Verifying...' : label),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: isLargeScreen ? 20 : 16,
          horizontal: isLargeScreen ? 24 : 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).scale();
  }

  Widget _buildScanTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment<bool>(
              value: true, icon: Icon(Iconsax.ticket), label: Text('Ticket')),
          ButtonSegment<bool>(
              value: false, icon: Icon(Iconsax.card), label: Text('Pass')),
        ],
        selected: {isTicketScanning},
        onSelectionChanged: (Set<bool> newSelection) {
          setState(() {
            isTicketScanning = newSelection.first;
          });
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildManualEntry(bool isLargeScreen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 32 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Manual Entry',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: 600.ms).slideX(),
            SizedBox(height: isLargeScreen ? 24 : 16),
            TextFormField(
              controller: _manualCodeController,
              decoration: InputDecoration(
                hintText: 'Enter code manually',
                prefixIcon:
                    Icon(isTicketScanning ? Iconsax.ticket : Iconsax.card),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(),
            SizedBox(height: isLargeScreen ? 24 : 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _verifyManualCode,
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Iconsax.tick_square),
              label: Text(_isLoading ? 'Verifying...' : 'Verify'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: isLargeScreen ? 20 : 16,
                  horizontal: isLargeScreen ? 24 : 16,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 600.ms).scale(),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY();
  }

  Future<void> _verifyScannedCode(String code) async {
    setState(() {
      _isLoading = true;
      _verificationResponse = null;
    });

    try {
      if (isTicketScanning) {
        final response = await _verificationService.verifyTicket(code);
        setState(() {
          _verificationResponse = response;
        });

        if (response.verificationMessage == 'Ticket is valid') {
          _showSuccessDialog(response);
        } else {
          _showErrorDialog(response);
        }
      } else {
        context.go('/pass?tagCode=$code');
      }
    } catch (e) {
      _toastManager.showErrorToast(context, 'Verification failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(TicketVerificationResponse response) {
    final confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    confettiController.play();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white.withOpacity(0.9),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.ticket_star,
                        color: Colors.green, size: 100),
                    const SizedBox(height: 24),
                    Text(
                      'Congratulations!',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your ticket is valid and ready for an amazing experience!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRow(context, 'Event',
                        response.eventInformation.eventName, Iconsax.calendar),
                    _buildInfoRow(context, 'Ticket Type',
                        response.zoneInformation.zoneName, Iconsax.ticket),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Iconsax.tick_circle),
                      label: const Text('Awesome, Got It!'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        confettiController.stop();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController,
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
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(TicketVerificationResponse response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Iconsax.close_circle, color: Colors.red, size: 80),
                const SizedBox(height: 20),
                Text(
                  'Ticket Invalid',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                ),
                const SizedBox(height: 20),
                Text(
                  response.verificationMessage ?? 'Unknown error occurred',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scanCode() async {
    try {
      _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
        context: context,
        onCode: (code) {
          if (code != null) {
            setState(() {
              scannedCode = code;
            });
            String? codec = extractCode(code);
            print("Code codec: $codec");
            String? codecode = extractCodeFromURL(codec);
            _verifyScannedCode(codecode);
          }
        },
      );
    } catch (e) {
      _toastManager.showErrorToast(context, 'Failed to scan code: $e');
    }
  }

  Future<void> _verifyManualCode() async {
    final code = _manualCodeController.text;
    if (code.isEmpty) {
      _toastManager.showErrorToast(context, 'Please enter a code');
      return;
    }

    setState(() {
      scannedCode = code;
    });
    await _verifyScannedCode(code);
  }
}

String extractCodeFromURL(String url) {
  final uri = Uri.parse(url);
  final segments = uri.pathSegments;
  if (segments.isNotEmpty) {
    return segments.last;
  } else {
    return url;
  }
}

String extractCode(String input) {
  return input.replaceFirst('Code scanned = ', '');
}

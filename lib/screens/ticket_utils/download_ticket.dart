import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'dart:html' as html;

import '../../api/api_service.dart';
import '../../models/ticket_download.dart';
import '../../services/ticket_download_service.dart';
import '../../services/toast_service.dart';
import '../../widgets/modern_ticketlist.dart';
import '../app/main_screen.dart';

class TicketDownloadScreen extends StatefulWidget {
  const TicketDownloadScreen({super.key});

  @override
  _TicketDownloadScreenState createState() => _TicketDownloadScreenState();
}

class _TicketDownloadScreenState extends State<TicketDownloadScreen> {
  final TextEditingController _orderController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TicketDownloadService ticketService = TicketDownloadService();
  final ToastManager _toastManager = ToastManager();
  int _activeStep = 0;
  List<String> _tickets = [];
  String? _errorMessage;
  bool _otpRequested = false;
  bool _otpVerified = false;
  bool _isLoading = false;
  TicketResponse? _ticketResponse;

  @override
  Widget build(BuildContext context) {
    return MainScreen(
      showSearchFAB: false,
      bodySliver: [
        SliverToBoxAdapter(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth > 600;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(isLargeScreen),
                  Flexible(
                    fit: FlexFit.loose,
                    child: isLargeScreen
                        ? _buildLargeScreenLayout()
                        : _buildSmallScreenLayout(),
                  ),
                ],
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildHeader(bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 24 : 16,
        horizontal: isLargeScreen ? 32 : 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Download Your Ticket',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ).animate().fadeIn(duration: 600.ms).slideX(),
          if (isLargeScreen) const SizedBox(height: 16),
          _buildStepper(isLargeScreen),
        ],
      ),
    );
  }

  Widget _buildStepper(bool isLargeScreen) {
    return EasyStepper(
      activeStep: _activeStep,
      lineStyle: LineStyle(
        lineLength: isLargeScreen ? 70 : 40,
        lineThickness: 1,
        lineSpace: 5,
        lineType: LineType.normal,
        defaultLineColor: Theme.of(context).dividerColor,
        finishedLineColor: Theme.of(context).primaryColor,
      ),
      stepShape: StepShape.circle,
      stepBorderRadius: 12,
      borderThickness: 2,
      padding: EdgeInsets.all(isLargeScreen ? 20 : 12),
      stepRadius: isLargeScreen ? 28 : 20,
      finishedStepBorderColor: Theme.of(context).primaryColor,
      finishedStepTextColor: Theme.of(context).primaryColor,
      finishedStepBackgroundColor: Theme.of(context).primaryColor,
      activeStepIconColor: Theme.of(context).colorScheme.onPrimary,
      activeStepBorderColor: Theme.of(context).primaryColor,
      activeStepBackgroundColor: Theme.of(context).primaryColor,
      steps: const [
        EasyStep(
          icon: Icon(Iconsax.ticket),
          title: 'Order',
          topTitle: true,
        ),
        EasyStep(
          icon: Icon(Iconsax.security_card),
          title: 'Verify',
          topTitle: true,
        ),
        EasyStep(
          icon: Icon(Iconsax.document_download),
          title: 'Download',
          topTitle: true,
        ),
      ],
      onStepReached: (index) {
        if (index < _activeStep) {
          setState(() => _activeStep = index);
        }
      },
    ).animate().fadeIn(duration: 800.ms).scale(delay: 300.ms);
  }

  Widget _buildLargeScreenLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildIllustration(),
        ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildContent(),
                const SizedBox(height: 32),
                _buildActionButton(isLargeScreen: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallScreenLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildContent(),
          const SizedBox(height: 24),
          _buildActionButton(isLargeScreen: false),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Center(
      child: Lottie.asset(
        'assets/lottie/download.json',
        width: 200,
        height: 200,
        fit: BoxFit.contain,
        delegates: LottieDelegates(
          values: [
            ValueDelegate.color(
              const ['**', 'Shape Layer 1', '**', 'Fill 1'],
              value: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    switch (_activeStep) {
      case 0:
        return _buildOrderInput();
      case 1:
        return _buildOtpInput();
      case 2:
        return _tickets.isEmpty
            ? _buildDownloadInfo()
            : ModernTicketList(
                tickets: _tickets,
                ticketInfor: _ticketResponse,
                onDownload: (ticket) => _downloadTicket(ticket),
              );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOrderInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Order Number',
          style: Theme.of(context).textTheme.titleLarge,
        ).animate().fadeIn(duration: 600.ms).slideX(),
        const SizedBox(height: 16),
        TextFormField(
          controller: _orderController,
          decoration: InputDecoration(
            hintText: 'e.g., 123456',
            prefixIcon: const Icon(Iconsax.ticket),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP',
          style: Theme.of(context).textTheme.titleLarge,
        ).animate().fadeIn(duration: 600.ms).slideX(),
        const SizedBox(height: 16),
        TextFormField(
          controller: _otpController,
          decoration: InputDecoration(
            hintText: '5-digit OTP',
            prefixIcon: const Icon(Iconsax.security_card),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          keyboardType: TextInputType.number,
          maxLength: 5,
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }

  Widget _buildDownloadInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your ticket is ready!',
          style: Theme.of(context).textTheme.titleLarge,
        ).animate().fadeIn(duration: 600.ms).slideX(),
        const SizedBox(height: 16),
        Text(
          'You can now download your ticket. Make sure to save it in a safe place.',
          style: Theme.of(context).textTheme.bodyLarge,
        ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(),
      ],
    );
  }

  Widget _buildActionButton({required bool isLargeScreen}) {
    IconData icon;
    String text;
    VoidCallback? onPressed;

    switch (_activeStep) {
      case 0:
        icon = Iconsax.arrow_right;
        text = 'Let\'s Go';
        onPressed = _requestOtp;
        break;
      case 1:
        icon = Iconsax.tick_square;
        text = 'Verify OTP';
        onPressed = _otpRequested ? _validateOtpAndFetchTickets : null;
        break;
      case 2:
        if (_tickets.isEmpty) {
          icon = Iconsax.refresh;
          text = 'Try Again';
          onPressed = () => setState(() {
                _activeStep = 0;
                _otpRequested = false;
                _otpVerified = false;
              });
        } else {
          return const SizedBox.shrink();
        }
        break;
      default:
        return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: isLargeScreen ? 12 : 16,
          horizontal: isLargeScreen ? 20 : 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: isLargeScreen ? const Size(200, 48) : const Size(160, 48),
        maximumSize: isLargeScreen ? const Size(200, 48) : const Size(160, 48),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isLargeScreen ? 18 : 24),
          SizedBox(width: isLargeScreen ? 6 : 8),
          Text(
            text,
            style: TextStyle(fontSize: isLargeScreen ? 14 : 16),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 600.ms).scale();
  }

  void _requestOtp() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    try {
      final message = await ticketService.requestOtp(_orderController.text);
      setState(() {
        _otpRequested = true;
        _activeStep = 1;
        _isLoading = false;
      });
      _toastManager.showSuccessToast(context, message);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _toastManager.showErrorToast(context, e.toString());
    }
  }

  void _validateOtpAndFetchTickets() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    try {
      final tickets = await ticketService.validateOtpAndFetchTickets(
        _otpController.text,
        _orderController.text,
      );
      setState(() {
        _tickets = tickets.tickets;
        _ticketResponse = tickets;
        _otpVerified = true;
        _activeStep = 2;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      _toastManager.showErrorToast(context, e.toString());
    }
  }

  Future<void> _downloadTicket(String ticketNumber) async {
    final baseUrl = ApiService().baseUrl;
    final dio = Dio();
    final toastManager = ToastManager();

    try {
      toastManager.showInfoToast(
          context, 'Downloading ticket: ticket_$ticketNumber.pdf');

      final url = "$baseUrl/api/events/pinnket/download/$ticketNumber";
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print(
                "Download progress: ${(received / total * 100).toStringAsFixed(0)}%");
          }
        },
      );

      if (kIsWeb) {
        final blob = html.Blob([response.data]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "ticket_$ticketNumber.pdf")
          ..click();

        html.Url.revokeObjectUrl(url);
      }

      toastManager.showSuccessToast(
          context, 'Downloaded ticket: ticket_$ticketNumber.pdf');
    } catch (e) {
      toastManager.showErrorToast(context, 'Failed to download ticket, Please try again');
    }
  }
}

String formatDate(String dateStr) {
  try {
    DateTime parsedDate = DateTime.parse(dateStr);
    print("dateStr: $dateStr");
    print("parsedDate: $parsedDate");
    return DateFormat('d MMMM, y').format(parsedDate);
  } catch (e) {
    print("Error parsing date: $e");
    return "Invalid date:$dateStr";
  }
}

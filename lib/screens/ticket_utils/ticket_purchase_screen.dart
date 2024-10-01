import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:pinnket/utils/layout.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:html' as html;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:widget_hydrator/widget_hydrator.dart';

import '../../models/event_models.dart';
import '../../providers/selectedevent_provider.dart';
import '../../providers/selectedzone_provider.dart';
import '../../services/events_service.dart';
import '../../services/ticket_purchase_service.dart';
import '../../services/toast_service.dart';
import '../../services/uganda_phonenumber.dart';
import '../../widgets/custom_textfield.dart';
import '../app/main_screen.dart';

class TicketPayment extends StatefulWidget {
  const TicketPayment({super.key});

  @override
  _TicketPaymentState createState() => _TicketPaymentState();
}

class _TicketPaymentState extends State<TicketPayment>
    with UltimateHydrationMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  final TicketPurchaseService _purchaseService = TicketPurchaseService();
  late SelectedEventProvider selectedEventProvider;
  late TicketSelectionProvider ticketSelectionProvider;
  final EventsService _eventsService = EventsService();
  final ToastManager _toastManager = ToastManager();
  Event? selectedEvent;
  bool isLoading = true;
  bool isSmsSelected = false;
  bool isProcessingPayment = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAndHydrate();
  }

  Future<void> _initializeAndHydrate() async {
    try {
      selectedEventProvider =
          Provider.of<SelectedEventProvider>(context, listen: false);
      ticketSelectionProvider =
          Provider.of<TicketSelectionProvider>(context, listen: false);

      await initializeHydration(HydrationConfig(useCompression: true));

      // Only hydrate if the data is null
      // if (selectedEventProvider.selectedEvent == null ||
      //     ticketSelectionProvider.selectedZoneId == null) {
      await ensureHydrated();
      // }

      // If still null after hydration, try to load from URL
      if (selectedEventProvider.selectedEvent == null) {
        final eid = _getEventIdFromUrl();
        if (eid != null) {
          await _loadEventDetails(eid);
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error initializing: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadEventDetails(String eid) async {
    try {
      final event = await _eventsService.getEventDetails(eid);
      selectedEventProvider.setSelectedEvent(event);
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching event details: $e';
      });
    }
  }

  void _retryPayment() {
    // Logic to retry the payment
    _handleCheckout();
  }

  String? _getEventIdFromUrl() {
    final String location = html.window.location.href;
    final uri = Uri.parse(location);
    final fragment = uri.fragment;
    final pathSegments = Uri.parse(fragment).pathSegments;
    if (pathSegments.length >= 2 && pathSegments[0] == 'events') {
      return pathSegments[1];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = isDisplayMobile(context);
    final Size screenSize = MediaQuery.of(context).size;
    return Consumer2<SelectedEventProvider, TicketSelectionProvider>(
      builder: (context, eventProvider, ticketProvider, child) {
        if (isLoading) {
          return MainScreen(
            bodySliver: [
              SliverToBoxAdapter(child: _buildShimmerLoading()),
            ],
          );
        }

        if (errorMessage != null) {
          return MainScreen(
            bodySliver: [
              SliverToBoxAdapter(child: Center(child: Text(errorMessage!))),
            ],
          );
        }

        if (eventProvider.selectedEvent == null ||
            ticketProvider.selectedZoneId == null) {
          return const MainScreen(
            bodySliver: [
              SliverToBoxAdapter(
                  child: Center(child: Text('No event or ticket selected'))),
            ],
          );
        }

        return MainScreen(
          showSearchFAB: false,
          isScrollable: true,
          showFooter: false,
          bodySliver: [
            SliverToBoxAdapter(
                child: SizedBox(
                    height: screenSize.height,
                    child: AutofillGroup(
                      onDisposeAction: AutofillContextAction.commit,
                      child: FormBuilder(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                          child: isSmallScreen
                              ? _buildMobileLayout(context)
                              : _buildDesktopLayout(context),
                        ),
                      ),
                    ))),
          ],
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 50,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 300,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverToBoxAdapter(
            child: _buildOrderSummary(context),
          ),
        ];
      },
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: _buildPaymentForm(context),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: _buildPaymentForm(context),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: _buildOrderSummary(context),
        ),
      ],
    );
  }

  Widget _buildPaymentForm(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Checkout',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
            const SizedBox(height: 16),
            _buildContactInformation(context),
            const SizedBox(height: 24),
            _buildPreferences(context),
            const SizedBox(height: 24),
            _buildPaymentMethod(context),
            const SizedBox(height: 24),
            _buildSecurityInfo(context),
            const SizedBox(height: 24),
            _buildCheckoutButton(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ).animate().slideX(begin: -0.1, end: 0, duration: 500.ms);
  }

  Widget _buildContactInformation(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = isDisplayMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        if (isSmallScreen)
          Column(
            children: [
              _buildTextField(
                context: context,
                name: 'first_name',
                label: 'First name',
                icon: Iconsax.user,
                autofillHints: [AutofillHints.givenName],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                context: context,
                name: 'last_name',
                label: 'Last name',
                icon: Iconsax.user,
                autofillHints: [AutofillHints.familyName],
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  context: context,
                  name: 'first_name',
                  label: 'First name',
                  icon: Iconsax.user,
                  autofillHints: [AutofillHints.givenName],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  context: context,
                  name: 'last_name',
                  label: 'Last name',
                  icon: Iconsax.user,
                  autofillHints: [AutofillHints.familyName],
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        CustomPhoneField(
          name: 'phone_number',
          label: 'Phone Number',
          hintText: '7XXXXXXXX',
          maxLength: 9,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          autofillHints: const [AutofillHints.telephoneNumber],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context: context,
          name: 'email',
          label: 'Email address',
          icon: Iconsax.sms,
          autofillHints: [AutofillHints.email],
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String name,
    required String label,
    required IconData icon,
    int? maxLength,
    String? hintText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    required Iterable<String> autofillHints,
  }) {
    final theme = Theme.of(context);
    return FormBuilderTextField(
      name: name,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
      ]),
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, size: 20, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      style: TextStyle(color: theme.colorScheme.onSurface),
    );
  }

  Widget _buildPreferences(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildCheckbox(context, 'keep_me_updated',
            'Keep me updated on more events and news'),
        _buildCheckbox(
            context, 'best_events', 'Send me emails about the best events'),
        _buildCheckbox(
            context, 'receive_ticket_email', 'Receive the ticket via email',
            initialValue: true, enabled: false),
        _buildCheckbox(
          context,
          'receive_ticket_sms',
          'Receive the ticket via SMS',
          onChanged: (bool? value) {
            setState(() {
              isSmsSelected = value ?? false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCheckbox(BuildContext context, String name, String label,
      {bool initialValue = false,
      bool enabled = true,
      ValueChanged<bool?>? onChanged}) {
    final theme = Theme.of(context);
    return FormBuilderCheckbox(
      name: name,
      title: Text(label, style: TextStyle(color: theme.colorScheme.onSurface)),
      initialValue: initialValue,
      enabled: enabled,
      onChanged: onChanged,
    );
  }

  Widget _buildPaymentMethod(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        FormBuilderRadioGroup(
          name: 'payment_method',
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
          ),
          wrapDirection: Axis.horizontal,
          options: [
            FormBuilderFieldOption(
              value: 'mobile_money',
              child:
                  _buildPaymentOption(context, 'Mobile Money', Iconsax.mobile),
            ),
            FormBuilderFieldOption(
              value: 'card_payment',
              child: _buildPaymentOption(context, 'Card Payment', Iconsax.card),
            ),
          ],
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Consumer2<SelectedEventProvider, TicketSelectionProvider>(
      builder: (context, eventProvider, ticketProvider, child) {
        final theme = Theme.of(context);
        final event = eventProvider.selectedEvent!;
        final ticketPrice = ticketProvider.selectedCategoryCost;
        final ticketCount = ticketProvider.ticketCount;
        final adminFee = 1000 * ticketCount;
        final smsFee = isSmsSelected ? 500 : 0;
        final totalPrice = ticketPrice * ticketCount + adminFee + smsFee;
        final NumberFormat currencyFormat = NumberFormat.currency(
            locale: 'en_US', symbol: 'UGX ', decimalDigits: 0);

        return Card(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 200,
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(event.evLogo!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryItem(context, 'Event', event.name!),
                    _buildSummaryItem(context,
                        '${ticketProvider.selectedZoneName}', '$ticketCount'),
                    _buildSummaryItem(context, 'Tickets Cost',
                        currencyFormat.format(ticketPrice * ticketCount)),
                    _buildSummaryItem(
                        context, 'Admin Fee', currencyFormat.format(adminFee)),
                    if (isSmsSelected)
                      _buildSummaryItem(
                          context, 'SMS Fee', currencyFormat.format(smsFee)),
                    const Divider(),
                    _buildSummaryItem(
                        context, 'Total', currencyFormat.format(totalPrice),
                        isTotal: true),
                  ],
                ),
              ),
            ],
          ),
        ).animate().slideX(begin: 0.1, end: 0, duration: 500.ms);
      },
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isProcessingPayment ? null : _handleCheckout,
        icon: isProcessingPayment
            ? SpinKitRing(
                color: theme.colorScheme.onPrimary,
                size: 20.0,
                lineWidth: 2.0,
              )
            : const Icon(Iconsax.money_send),
        label: Text(isProcessingPayment ? 'Processing...' : 'Complete Payment'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  void _handleCheckout() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final formData = _formKey.currentState!.value;
      final phoneNumber = formData['phone_number'] as String?;
      final firstName = formData['first_name'] as String?;
      final lastName = formData['last_name'] as String?;
      final email = formData['email'] as String?;
      final paymentMethod = formData['payment_method'] as String?;
      final isSmsSelected = formData['receive_ticket_sms'] as bool? ?? false;

      if (phoneNumber == null ||
          firstName == null ||
          lastName == null ||
          email == null ||
          paymentMethod == null) {
        _toastManager.showInfoToast(
            context, 'Please fill in all required fields');
        return;
      }

      final ticketPrice = ticketSelectionProvider.selectedCategoryCost;
      final ticketCount = ticketSelectionProvider.ticketCount;
      final adminFee = 1000 * ticketCount;
      final smsFee = isSmsSelected ? 500 : 0;
      final totalPrice = ticketPrice * ticketCount + adminFee + smsFee;

      setState(() {
        isProcessingPayment = true;
      });

      try {
        if (paymentMethod == 'mobile_money') {
          await _handleMobileMoneyPayment(
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName,
            email: email,
            isSmsSelected: isSmsSelected,
            totalPrice: totalPrice.toDouble(),
          );
        } else if (paymentMethod == 'card_payment') {
          await _handleCardPayment(
            phoneNumber: phoneNumber,
            firstName: firstName,
            lastName: lastName,
            email: email,
            isSmsSelected: isSmsSelected,
            totalPrice: totalPrice.toDouble(),
          );
        }
      } catch (e) {
        setState(() {
          isProcessingPayment = false;
        });

        context.go(
          '/payment-failure?errorMessage=${Uri.encodeComponent(e.toString())}',
          extra: _retryPayment,
        );
      }
    }
  }

  Future<void> _handleMobileMoneyPayment({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String email,
    required bool isSmsSelected,
    required double totalPrice,
  }) async {
    final provider = UgandanProviderDetector.getProvider(phoneNumber);

    if (provider == null) {
      _toastManager.showInfoToast(context, 'Invalid phone number');
      return;
    }

    _showPaymentInstructionsDialog(
        context, selectedEventProvider.selectedEvent?.eventNumber ?? '');

    final result = await _purchaseService.purchaseTicket(
      zid: ticketSelectionProvider.selectedZoneId!,
      ticketNumber: ticketSelectionProvider.ticketCount.toString(),
      name: '$firstName $lastName',
      email: email,
      phone: "256$phoneNumber",
      provider: provider,
      sendOnMail: true,
      sendOnPhone: isSmsSelected,
      amount: totalPrice.toString(),
    );

    setState(() {
      isProcessingPayment = false;
    });

    _toastManager.showSuccessToast(context, result);
    context.go(
        '/payment-success?amount=$totalPrice&eventName=${selectedEventProvider.selectedEvent?.name}');
  }

  Future<void> _handleCardPayment({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String email,
    required bool isSmsSelected,
    required double totalPrice,
  }) async {
    final dpoUrl = await _purchaseService.purchaseTicketDPO(
      zid: ticketSelectionProvider.selectedZoneId!,
      ticketNumber: ticketSelectionProvider.ticketCount.toString(),
      name: '$firstName $lastName',
      email: email,
      phone: "256$phoneNumber",
      sendOnMail: true,
      sendOnPhone: isSmsSelected,
      amount: totalPrice.toString(),
    );

    setState(() {
      isProcessingPayment = false;
    });

    // open a headless browser to the DPO payment page in the same tab
    html.window.location.href = dpoUrl;
  }

  void _showPaymentInstructionsDialog(BuildContext context, String eventId) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Payment Instructions',
              style: theme.textTheme.headlineSmall),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInstructionStep(context, '1',
                    'A Payment prompt has been sent to the phone number provided.'),
                _buildInstructionStep(context, '2',
                    'Enter your MobileMoney PIN on your mobile phone.'),
                _buildInstructionStep(context, '3',
                    'PinnKET automatically receives your payment.'),
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
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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

  @override
  Future<void> initializeHydration(HydrationConfig config) async {
    try {
      await super.initializeHydration(config);
    } catch (e) {
      print('Error initializing hydration: $e');
      // Handle the error, possibly by setting a default state
      initializeDefaultState();
    }
  }

  @override
  void initializeDefaultState() {}

  @override
  void hydrateFromJson(Map<String, dynamic> json) {
    try {
      setState(() {
        // Only set values if they are null or not set
        isLoading = isLoading;
        isProcessingPayment = isProcessingPayment;
        errorMessage ??= json['errorMessage'];

        if (_formKey.currentState?.value == null && json['formData'] != null) {
          _formKey.currentState?.patchValue(json['formData']);
        }

        if (json['ticketSelectionData'] != null) {
          final ticketData = json['ticketSelectionData'];
          if (ticketSelectionProvider.selectedZoneId == null) {
            ticketSelectionProvider
                .setSelectedZoneId(ticketData['selectedZoneId']);
          }
          if (ticketSelectionProvider.selectedZoneName == null) {
            ticketSelectionProvider
                .setSelectedZoneName(ticketData['selectedZoneName']);
          }
          if (ticketSelectionProvider.selectedCategoryCost == null) {
            ticketSelectionProvider
                .setSelectedCategoryCost(ticketData['selectedCategoryCost']);
            print(
                "selectedCategoryCost: ${ticketData['selectedCategoryCost']}");
          }
          if (ticketSelectionProvider.ticketCount == null) {
            ticketSelectionProvider.setTicketCount(ticketData['ticketCount']);
            print("ticketCount: ${ticketData['ticketCount']}");
          }
        }
      });
    } catch (e) {
      print('Error hydrating state: $e');
      initializeDefaultState();
    }
  }

  @override
  Map<String, dynamic> persistToJson() {
    try {
      return {
        'isLoading': isLoading,
        'isProcessingPayment': isProcessingPayment,
        'errorMessage': errorMessage,
        'formData': _formKey.currentState?.value,
        'ticketSelectionData': {
          'selectedZoneId': ticketSelectionProvider.selectedZoneId,
          'selectedCategoryCost': ticketSelectionProvider.selectedCategoryCost,
          'ticketCount': ticketSelectionProvider.ticketCount,
          'selectedZoneName': ticketSelectionProvider.selectedZoneName,
        },
      };
    } catch (e) {
      print('Error persisting state: $e');
      return {
        'isLoading': true,
        'isProcessingPayment': false,
      };
    }
  }
}

Widget _buildPaymentOption(BuildContext context, String label, IconData icon) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(label,
            style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface)),
      ],
    ),
  );
}

Widget _buildSecurityInfo(BuildContext context) {
  final theme = Theme.of(context);
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Text(
          "All payments are made through YO UGANDA LIMITED and DPO.",
          style: TextStyle(
              fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security_outlined,
                size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              "Payments are secured and encrypted.",
              style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildSummaryItem(BuildContext context, String title, String amount,
    {bool isTotal = false}) {
  final theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            flex: 3,
            child: Text(
              title,
              style: (isTotal
                      ? theme.textTheme.bodyMedium
                      : theme.textTheme.bodySmall)
                  ?.copyWith(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )),
        Expanded(
          child: Text(
            amount,
            style: (isTotal
                    ? theme.textTheme.bodyMedium
                    : theme.textTheme.bodySmall)
                ?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis, // Handle overflow
          ),
        )
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:pinnket/services/ticket_transfer_service.dart';
import '../../services/toast_service.dart';
import '../../services/uganda_phonenumber.dart';
import 'dart:html' as html;

class Payment extends StatefulWidget {
  final String ticketNumber;
  final String receiverEmail;
  final String receiverName;
  final String receiverPhone;
  final String? provider;
  final String? phoneNumber;
  final String? payerName;

  const Payment({
    super.key,
    required this.ticketNumber,
    required this.receiverEmail,
    required this.receiverName,
    required this.receiverPhone,
    this.provider,
    this.phoneNumber,
    this.payerName,
  });

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TicketTransferService _ticketTransferService = TicketTransferService();
  final ToastManager _toastManager = ToastManager();

  String? _paymentMethod;
  bool _isLoading = false;
  String? _detectedProvider;

  @override
  void initState() {
    super.initState();
    _detectedProvider = widget.phoneNumber != null
        ? UgandanProviderDetector.getProvider(widget.phoneNumber!)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AutofillGroup(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildContactInfo(theme),
                  const SizedBox(height: 20),
                  _buildPaymentMethod(size),
                  const SizedBox(height: 20),
                  _buildSecurityInfo(),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/lottie/payment.json', width: 100, height: 100),
        const Text(
          'Ticket Transfer Payment',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildContactInfo(ThemeData theme) {
    return Column(
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
                child: _buildTextField('first_name', 'First name',
                    theme: theme, prefixIcon: Iconsax.user)),
            const SizedBox(width: 10),
            Expanded(
                child: _buildTextField('last_name', 'Last name',
                    theme: theme, prefixIcon: Iconsax.user)),
          ],
        ),
        const SizedBox(height: 10),
        _buildTextField(
          'phone_number',
          'Phone number',
          hintText: 'eg 2567XX XXX XXX',
          keyboardType: TextInputType.phone,
          theme: theme,
          prefixIcon: Iconsax.call,
          onChanged: (value) {
            setState(() {
              _detectedProvider =
                  UgandanProviderDetector.getProvider(value ?? '');
            });
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethod(Size size) {
    return FormBuilderRadioGroup<String>(
      name: 'payment_method',
      decoration: const InputDecoration(labelText: 'Payment Method'),
      onChanged: (value) => setState(() => _paymentMethod = value),
      options: [
        FormBuilderFieldOption(
          value: 'mobile_money',
          child: Image.asset('assets/images/mtn.png',
              width: size.width * 0.06, height: size.height * 0.05),
        ),
        FormBuilderFieldOption(
          value: 'card_payment',
          child: Image.asset('assets/images/pay_by_cards.png',
              width: size.width * 0.06, height: size.height * 0.05),
        ),
      ],
    );
  }

  Widget _buildSecurityInfo() {
    return const Column(
      children: [
        Text(
          "All payments are made through YO UGANDA LIMITED.",
          style: TextStyle(fontSize: 12),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security_outlined, size: 15),
            Text(
              "Payments are secured and encrypted.",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePayment,
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_forward),
                SizedBox(width: 5),
                Text('Transfer Ticket'),
              ],
            ),
    );
  }

  Widget _buildTextField(
    String name,
    String label, {
    bool enabled = true,
    void Function(String?)? onChanged,
    String? hintText,
    IconData? prefixIcon,
    required ThemeData theme,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: FormBuilderTextField(
        name: name,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle:
              theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          floatingLabelStyle:
              theme.textTheme.bodyMedium?.copyWith(color: theme.primaryColor),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.primaryColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: theme.iconTheme.color)
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _handlePayment() async {
    if (_formKey.currentState!.saveAndValidate()) {
      setState(() => _isLoading = true);

      final formData = _formKey.currentState!.value;
      final firstName = formData['first_name'] as String?;
      final lastName = formData['last_name'] as String?;
      String? phoneNumber = formData['phone_number'] as String?;

      if (firstName == null || lastName == null || phoneNumber == null) {
        _toastManager.showErrorToast(context, "All fields are required");
        setState(() => _isLoading = false);
        return;
      }

      phoneNumber = sanitizePhoneNumber(phoneNumber);

      try {
        final response = await _ticketTransferService.initiateTicketTransfer(
          widget.ticketNumber,
          widget.receiverEmail,
          widget.receiverName,
          widget.ticketNumber,
          payerName: '$firstName $lastName',
          phoneNumber: phoneNumber,
          provider: _detectedProvider,
          isCard: _paymentMethod == 'card_payment',
        );

        if (_paymentMethod == 'card_payment') {
          _openUrlInCurrentTab(response);
        } else {
          _toastManager.showSuccessToast(context, response);
          Navigator.of(context).pop();
        }
      } catch (e) {
        _toastManager.showErrorToast(context, e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openUrlInCurrentTab(String url) {
    html.window.open(url, '_self');
  }
}

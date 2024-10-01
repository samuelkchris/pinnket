import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinnket/screens/ticket_utils/transfer_payment_screen.dart';
import 'package:pinnket/services/ticket_transfer_service.dart';

import '../../services/toast_service.dart';

class SendTicket extends StatefulWidget {
  const SendTicket({super.key});

  @override
  State<SendTicket> createState() => _SendTicketState();
}

class _SendTicketState extends State<SendTicket> {
  final formKey = GlobalKey<FormBuilderState>();
  final TicketTransferService _ticketTransferService = TicketTransferService();
  bool _isLoading = false;
  final ToastManager _toastManager = ToastManager();

  Future<void> _handleSubmit() async {
    if (formKey.currentState!.saveAndValidate()) {
      setState(() {
        _isLoading = true;
      });

      final formData = formKey.currentState!.value;
      final ticketNumber = formData['ticket_number'] as String?;
      final firstName = formData['first_name'] as String?;
      final lastName = formData['last_name'] as String?;
      final email = formData['email'] as String?;
      final phoneNumber = formData['phone_number'] as String?;

      if (ticketNumber == null ||
          firstName == null ||
          lastName == null ||
          email == null ||
          phoneNumber == null) {
        _toastManager.showErrorToast(context, "All fields are required");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        final isFirstTransfer =
            await _ticketTransferService.isFirstTransfer(ticketNumber);
        print(isFirstTransfer);

        if (!isFirstTransfer['isFirst']) {
          // Navigate to payment screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Payment(
                ticketNumber: formData['ticket_number'],
                receiverEmail: formData['email'],
                receiverName:
                    '${formData['first_name']} ${formData['last_name']}',
                receiverPhone: formData['phone_number'],
                provider: null,
                phoneNumber: null,
                payerName: null,
              ),
            ),
          );
        } else {
          // Continue with transfer
          await _initiateTransfer(formData);
          _toastManager.showSuccessToast(
              context, "Transfer initiated successfully");
        }
      } catch (e) {
        _toastManager.showErrorToast(context, e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initiateTransfer(Map<String, dynamic> formData) async {
    await _ticketTransferService.initiateTicketTransfer(
      formData['ticket_number'],
      formData['email'],
      '${formData['first_name']} ${formData['last_name']}',
      formData['phone_number'], isCard: false,
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        return Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
            child: FormBuilder(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Recipient Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  if (isSmallScreen) ...[
                    _buildTextField(context, 'first_name', 'First name *',
                        prefixIcon: Iconsax.user),
                    const SizedBox(height: 14),
                    _buildTextField(context, 'last_name', 'Last name *',
                        prefixIcon: Iconsax.user),
                  ] else
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                context, 'first_name', 'First name *',
                                prefixIcon: Iconsax.user)),
                        const SizedBox(width: 14),
                        Expanded(
                            child: _buildTextField(
                                context, 'last_name', 'Last name *',
                                prefixIcon: Iconsax.user)),
                      ],
                    ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    context,
                    'phone_number',
                    'Phone number *',
                    hintText: 'eg 2567XX XXX XXX',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Iconsax.call,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    context,
                    'email',
                    'Email address *',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Iconsax.sms,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ticket Information',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(context, 'ticket_number', 'Ticket Number *',
                      prefixIcon: Iconsax.ticket),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Iconsax.send_1, size: 18),
                                SizedBox(width: 8),
                                Text('Transfer Ticket',
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

        );
      },
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String name,
    String label, {
    TextInputType? keyboardType,
    IconData? prefixIcon,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: FormBuilderTextField(
        name: name,
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
        style: theme.textTheme.bodyLarge,
        cursorColor: theme.primaryColor,
        validator: validator,
      ),
    );
  }
}

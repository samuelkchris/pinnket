import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinnket/services/ticket_transfer_service.dart';
import '../../services/toast_service.dart';
import '../../services/uganda_phonenumber.dart';

class ReceiveTicket extends StatefulWidget {
  const ReceiveTicket({super.key});

  @override
  State<ReceiveTicket> createState() => _ReceiveTicketState();
}

class _ReceiveTicketState extends State<ReceiveTicket> {
  final _formKey = GlobalKey<FormBuilderState>();
  final TicketTransferService _ticketTransferService = TicketTransferService();
  final ToastManager _toastManager = ToastManager();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        return  Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
            child: FormBuilder(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Recipient Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    'email',
                    'Email address *',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Iconsax.sms,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    'secret_code',
                    'Secret Code *',
                    prefixIcon: Iconsax.password_check,
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    context,
                    'ticket_number',
                    'Ticket Number *',
                    prefixIcon: Iconsax.ticket,
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleReceiveTicket,
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
                                Icon(Iconsax.import, size: 18),
                                SizedBox(width: 8),
                                Text('Receive Ticket',
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

  Future<void> _handleReceiveTicket() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final formData = _formKey.currentState!.value;

      if (formData['ticket_number'] == null ||
          formData['ticket_number'].isEmpty ||
          formData['email'] == null ||
          formData['email'].isEmpty ||
          formData['secret_code'] == null ||
          formData['secret_code'].isEmpty) {
        _toastManager.showErrorToast(context, 'All fields are required.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final message = await _ticketTransferService.confirmTicketTransfer(
          formData['ticket_number'],
          formData['email'],
          formData['secret_code'],
        );
        _toastManager.showSuccessToast(context, message);

        // Optionally, navigate to a success screen or clear the form
        _formKey.currentState!.reset();
      } catch (e) {
        _toastManager.showErrorToast(context, e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BookingConfirmationCheckout extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  const BookingConfirmationCheckout({super.key, required this.bookingDetails});

  @override
  _BookingConfirmationCheckoutState createState() => _BookingConfirmationCheckoutState();
}

class _BookingConfirmationCheckoutState extends State<BookingConfirmationCheckout> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPaymentMethod = 'Mobile Money';
  String _name = '';
  String _email = '';
  String _phone = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildWideLayout();
          } else {
            return _buildNarrowLayout();
          }
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: _buildBookingSummary(),
          ),
        ),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: _buildCheckoutForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBookingSummary(),
          _buildCheckoutForm(),
        ],
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking Summary', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildSummaryItem(Iconsax.bus, 'Bus', widget.bookingDetails['bus'].company),
            _buildSummaryItem(Iconsax.location, 'From - To', '${widget.bookingDetails['from']} - ${widget.bookingDetails['to']}'),
            _buildSummaryItem(Iconsax.calendar, 'Date', DateFormat('MMM dd, yyyy').format(widget.bookingDetails['departureTime'])),
            _buildSummaryItem(Iconsax.clock, 'Time', '${DateFormat('HH:mm').format(widget.bookingDetails['departureTime'])} - ${DateFormat('HH:mm').format(widget.bookingDetails['arrivalTime'])}'),
            _buildSummaryItem(Iconsax.ticket, 'Seats', widget.bookingDetails['selectedSeats'].join(', ')),
            _buildSummaryItem(Iconsax.money, 'Total Price', '\$${widget.bookingDetails['price'].toStringAsFixed(2)}'),
            if (widget.bookingDetails['isRefundable'])
              _buildSummaryItem(Iconsax.shield_tick, 'Refundable', 'Yes'),
            _buildSummaryItem(Iconsax.cake, 'Meal Preference', widget.bookingDetails['mealPreference']),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutForm() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Personal Information', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Full Name',
                icon: Iconsax.user,
                onSaved: (value) => _name = value ?? '',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Email',
                icon: Iconsax.sms,
                onSaved: (value) => _email = value ?? '',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Phone Number',
                icon: Iconsax.call,
                onSaved: (value) => _phone = value ?? '',
                validator: (value) => value?.isEmpty ?? true ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 24),
              Text('Payment Method', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildPaymentMethodSelection(),
              const SizedBox(height: 24),
              if (_selectedPaymentMethod == 'Mobile Money')
                _buildMobileMoneyFields()
              else
                _buildCardPaymentFields(),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Confirm and Pay'),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Row(
      children: [
        Expanded(
          child: _buildPaymentOption(
            title: 'Mobile Money',
            icon: Iconsax.mobile,
            isSelected: _selectedPaymentMethod == 'Mobile Money',
            onTap: () => setState(() => _selectedPaymentMethod = 'Mobile Money'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPaymentOption(
            title: 'Card',
            icon: Iconsax.card,
            isSelected: _selectedPaymentMethod == 'Card',
            onTap: () => setState(() => _selectedPaymentMethod = 'Card'),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileMoneyFields() {
    return Column(
      children: [
        _buildTextField(
          label: 'Mobile Money Number',
          icon: Iconsax.mobile,
          onSaved: (value) {},
          validator: (value) => value?.isEmpty ?? true ? 'Please enter your mobile money number' : null,
        ),
      ],
    );
  }

  Widget _buildCardPaymentFields() {
    return Column(
      children: [
        _buildTextField(
          label: 'Card Number',
          icon: Iconsax.card,
          onSaved: (value) {},
          validator: (value) => value?.isEmpty ?? true ? 'Please enter your card number' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Expiry Date',
                icon: Iconsax.calendar,
                onSaved: (value) {},
                validator: (value) => value?.isEmpty ?? true ? 'Please enter expiry date' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'CVV',
                icon: Iconsax.password_check,
                onSaved: (value) {},
                validator: (value) => value?.isEmpty ?? true ? 'Please enter CVV' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Process the booking
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed! Processing payment...')),
      );
      // Navigate to confirmation page or show a dialog
    }
  }
}
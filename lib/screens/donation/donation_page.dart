import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pinnket/utils/hider.dart';
import 'package:pinnket/utils/layout.dart';
import 'dart:html' as html;
import '../../services/donation_service.dart';
import '../../services/toast_service.dart';
import '../../services/uganda_phonenumber.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loader.dart';

class DonationPage extends StatefulWidget {
  final String eventName;
  final double goalAmount;
  final double raisedAmount;
  final String eid;
  final String evLogo;

  const DonationPage({
    super.key,
    required this.eventName,
    required this.goalAmount,
    required this.raisedAmount,
    required this.eid,
    required this.evLogo,
  });

  @override
  _DonationPageState createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  double _selectedAmount = 1000;
  bool _isCustomAmount = false;
  double? _customTipAmount = 0;
  final TextEditingController _customTipController = TextEditingController();

  bool _isCustomTipAmount = false;
  double _tipPercentage = 5;
  int _currentStep = 0;

  final DonationService _donationService = DonationService();
  late ConfettiController _confettiController;
  final ToastManager _toastManager = ToastManager();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
    callJavaScriptMethods();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _customTipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: _buildEventInfoSection(),
        ),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: _buildDonationForm(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200.0,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildEventInfoSection(),
            title: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity:
                      constraints.biggest.height <= kToolbarHeight ? 1.0 : 0.0,
                  child: Text(
                    widget.eventName,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildDonationForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfoSection() {
    final NumberFormat currencyFormat = NumberFormat.currency(
        locale: 'en_US', symbol: 'UGX ', decimalDigits: 0);
    final percentRaised =
        (widget.raisedAmount / widget.goalAmount).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.evLogo),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.transparent.withOpacity(0.5), BlendMode.darken),
            ),
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     Theme.of(context).colorScheme.primary,
            //     Theme.of(context).colorScheme.secondary,
            //   ],
            // ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.eventName,
                      style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    )),
                const SizedBox(height: 24),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${currencyFormat.format(widget.raisedAmount)} raised of ${currencyFormat.format(widget.goalAmount)} goal',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.white),
                    )),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentRaised,
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDonationForm() {
    return FormBuilder(
      key: _formKey,
      child: Stepper(
        physics: const ClampingScrollPhysics(),
        currentStep: _currentStep,
        onStepContinue: () {
          if (_validateCurrentStep()) {
            if (_currentStep < 2) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              _submitDonation();
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: details.onStepContinue,
                  icon: Icon(_currentStep < 2
                      ? Iconsax.arrow_right_3
                      : Iconsax.tick_circle),
                  label: Text(_currentStep < 2 ? 'Continue' : 'Donate Now'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: details.onStepCancel,
                    icon: const Icon(Iconsax.arrow_left_2),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Donation Amount'),
            content: _buildAmountSection(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Your Information'),
            content: _buildDonorInfoSection(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Payment Method'),
            content: _buildPaymentMethodSection(),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    _formKey.currentState!.save();
    switch (_currentStep) {
      case 0:
        return _validateAmountStep();
      case 1:
        return _validateDonorInfoStep();
      case 2:
        return _validatePaymentMethodStep();
      default:
        return false;
    }
  }

  bool _validateAmountStep() {
    if (_isCustomAmount) {
      if (_formKey.currentState!.fields['customAmount'] == null ||
          _formKey.currentState!.fields['customAmount']!.value == null) {
        _showValidationError('Please enter a custom amount');
        return false;
      }
      if (double.tryParse(
                  _formKey.currentState!.fields['customAmount']!.value) ==
              null ||
          double.parse(_formKey.currentState!.fields['customAmount']!.value) <=
              0) {
        _showValidationError('Please enter a valid amount');
        return false;
      }
    }
    if (_selectedAmount <= 0) {
      _showValidationError('Please select a valid donation amount');
      return false;
    }
    return true;
  }

  bool _validateDonorInfoStep() {
    _formKey.currentState!.save();

    // Validate name
    final nameField = _formKey.currentState!.fields['name'];
    if (nameField?.value == null ||
        nameField!.value.toString().trim().isEmpty) {
      _showValidationError('Please enter your name');
      return false;
    }

    // Validate email
    final emailField = _formKey.currentState!.fields['email'];
    if (emailField?.value == null ||
        emailField!.value.toString().trim().isEmpty) {
      _showValidationError('Please enter your email address');
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailField.value.toString())) {
      _showValidationError('Please enter a valid email address');
      return false;
    }

    // Validate phone
    final phoneField = _formKey.currentState!.fields['phone'];
    if (phoneField?.value == null ||
        phoneField!.value.toString().trim().isEmpty) {
      _showValidationError('Please enter your phone number');
      return false;
    }
    if (!RegExp(r'^\d{9}$').hasMatch(phoneField.value.toString())) {
      _showValidationError('Please enter a valid 9-digit phone number');
      return false;
    }

    return true;
  }

  bool _validatePaymentMethodStep() {
    if (_formKey.currentState!.fields['payment_method']?.value == null) {
      _showValidationError('Please select a payment method');
      return false;
    }
    return true;
  }

  void _showValidationError(String message) {
    _toastManager.showErrorToast(context, message);
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select donation amount',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildAmountSelection(),
        const SizedBox(height: 24),
        _buildTipSection(),
        const SizedBox(height: 24),
        _buildDonationSummary(),
      ],
    );
  }

  Widget _buildAmountSelection() {
    final NumberFormat currencyFormat = NumberFormat.currency(
        locale: 'en_US', symbol: 'UGX ', decimalDigits: 0);
    final List<double> amounts = [
      1000,
      max(widget.goalAmount * 0.001, 1000),
      max(widget.goalAmount * 0.005, 1000),
      max(widget.goalAmount * 0.01, 1000),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (double amount in amounts) _buildAmountChip(amount, currencyFormat),
        _buildCustomAmountChip(),
      ],
    );
  }

  Widget _buildAmountChip(double amount, NumberFormat currencyFormat) {
    return ChoiceChip(
      label: Text(currencyFormat.format(amount)),
      selected: _selectedAmount == amount && !_isCustomAmount,
      onSelected: (selected) {
        setState(() {
          _selectedAmount = amount;
          _isCustomAmount = false;
        });
      },
    );
  }

  Widget _buildCustomAmountChip() {
    return Column(
      children: [
        ChoiceChip(
          label: const Text('Custom'),
          selected: _isCustomAmount,
          onSelected: (selected) {
            setState(() {
              _isCustomAmount = selected;
            });
          },
        ),
        if (_isCustomAmount)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CustomAmountField(
              name: 'customAmount',
              label: 'Enter amount',
              hintText: 'Enter amount',
              onEditingComplete: () {
                setState(() {
                  _isCustomAmount = true;
                });
              },
              onSubmitted: (value) {
                if (value != null && value.isNotEmpty) {
                  setState(() {
                    _selectedAmount = double.parse(value);
                  });
                }
              },
              onTap: () {
                setState(() {
                  _isCustomAmount = true;
                });
              },
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  setState(() {
                    _selectedAmount = double.parse(value);
                  });
                }
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              autofillHints: const [AutofillHints.telephoneNumber],
            ),

            // FormBuilderTextField(
            //   name: 'customAmount',
            //   decoration: InputDecoration(
            //     labelText: 'Enter amount',
            //     prefixIcon: const Icon(Iconsax.dollar_circle),
            //     border:
            //         OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            //   ),
            //   keyboardType: TextInputType.number,
            //   validator: FormBuilderValidators.compose([
            //     FormBuilderValidators.required(),
            //     FormBuilderValidators.numeric(),
            //     FormBuilderValidators.min(1),
            //   ]),
            //   autovalidateMode: AutovalidateMode.onUserInteraction,
            //   onChanged: (value) {
            //     if (value != null && value.isNotEmpty) {
            //       setState(() {
            //         _selectedAmount = double.parse(value);
            //       });
            //     }
            //   },
            //   onSubmitted: (value) {
            //     if (value != null && value.isNotEmpty) {
            //       setState(() {
            //         _selectedAmount = double.parse(value);
            //       });
            //     }
            //   },
            //   onTap: () {
            //     setState(() {
            //       _isCustomAmount = true;
            //     });
            //   },
            //   onEditingComplete: () {
            //     setState(() {
            //       _isCustomAmount = true;
            //     });
            //   },
            // ),
          ),
      ],
    );
  }

  Widget _buildTipSection() {
    double tipAmount = _calculateTipAmount();
    final NumberFormat currencyFormat = NumberFormat.currency(
        locale: 'en_US', symbol: 'UGX ', decimalDigits: 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Support PinnKET', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Add a tip to help PinnKET continue providing this platform for meaningful events.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (!_isCustomTipAmount)
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _tipPercentage,
                  min: 0,
                  max: 30,
                  divisions: 30,
                  label: '${_tipPercentage.round()}%',
                  onChanged: (value) {
                    setState(() {
                      _tipPercentage = value;
                      _customTipAmount = null;
                      _customTipController.clear();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${_tipPercentage.round()}%',
                      style: Theme.of(context).textTheme.titleMedium),
                  Text(currencyFormat.format(tipAmount),
                      style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Custom Tip:',
                  style: Theme.of(context).textTheme.titleMedium),
              Text('UGX ${_customTipAmount?.toStringAsFixed(0) ?? '0'}',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        if (!_isCustomTipAmount && _tipPercentage == 0) _buildZeroTipCard(),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            icon: const Icon(Iconsax.edit),
            label: Text(
                _isCustomTipAmount ? 'Use percentage tip' : 'Add custom tip'),
            onPressed: _toggleCustomTipAmount,
          ),
        ),
        if (_isCustomTipAmount) _customTipAmountSection(),
      ],
    );
  }

  Widget _customTipAmountSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: CustomAmountField(
        name: 'customTipAmount',
        label: 'Enter custom tip amount',
        hintText: 'Enter amount',
        onChanged: (value) {
          if (value != null && value.isNotEmpty) {
            setState(() {
              _customTipAmount = double.parse(value);
            });
          } else {
            setState(() {
              _customTipAmount = null;
            });
          }
        },
      ),
      //
      // FormBuilderTextField(
      //   name: 'customTipAmount',
      //   controller: _customTipController,
      //   decoration: InputDecoration(
      //     labelText: 'Enter custom tip amount',
      //     prefixIcon: const Icon(Iconsax.dollar_circle),
      //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      //   ),
      //   keyboardType: TextInputType.number,
      //   validator: FormBuilderValidators.compose([
      //     FormBuilderValidators.required(),
      //     FormBuilderValidators.numeric(),
      //     FormBuilderValidators.min(0),
      //   ]),
      //   autovalidateMode: AutovalidateMode.onUserInteraction,
      //   onChanged: (value) {
      //     if (value != null && value.isNotEmpty) {
      //       setState(() {
      //         _customTipAmount = double.parse(value);
      //       });
      //     } else {
      //       setState(() {
      //         _customTipAmount = null;
      //       });
      //     }
      //   },
      // ),
    );
  }

  Widget _buildZeroTipCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.heart,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Tip Makes a Difference',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Adding a tip means being a key part of improving the services for donors like you and the campaigns you support.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonationSummary() {
    final NumberFormat currencyFormat = NumberFormat.currency(
        locale: 'en_US', symbol: 'UGX ', decimalDigits: 0);
    double tipAmount = _calculateTipAmount();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Donation Summary',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Donation:'),
                Text(currencyFormat.format(_selectedAmount)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_isCustomTipAmount
                    ? 'Custom Tip:'
                    : 'Tip (${_tipPercentage.round()}%):'),
                Text(currencyFormat.format(tipAmount)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:'),
                Text(
                  currencyFormat.format(_selectedAmount + tipAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTipAmount() {
    if (_isCustomTipAmount && _customTipAmount != null) {
      return _customTipAmount!;
    } else {
      return (_selectedAmount * _tipPercentage / 100).roundToDouble();
    }
  }

  void _toggleCustomTipAmount() {
    setState(() {
      _isCustomTipAmount = !_isCustomTipAmount;
      if (_isCustomTipAmount) {
        _tipPercentage = 0;
        _customTipController.clear();
        _customTipAmount = null;
      } else {
        _tipPercentage = 5; // Reset to default percentage
        _customTipAmount = null;
      }
    });
  }

  Widget _buildDonorInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderTextField(
          name: 'name',
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: const Icon(Iconsax.user),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: FormBuilderValidators.required(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'email',
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Iconsax.sms),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            FormBuilderValidators.email(),
          ]),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
        const SizedBox(height: 16),
        CustomPhoneField(
          name: 'phone',
          label: 'Phone Number',
          hintText: '7XXXXXXXX',
          maxLength: 9,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          autofillHints: const [AutofillHints.telephoneNumber],
        ),
        const SizedBox(height: 24),
        Text(
          'Your support means the world to us and helps make this event possible. Thank you for your generosity!',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return FormBuilderRadioGroup(
      name: 'payment_method',
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      options: const [
        FormBuilderFieldOption(
          value: 'creditCard',
          child: Row(
            children: [
              Icon(Iconsax.card),
              SizedBox(width: 8),
              Text('Card'),
            ],
          ),
        ),
        FormBuilderFieldOption(
          value: 'mobileMoney',
          child: Row(
            children: [
              Icon(Iconsax.mobile),
              SizedBox(width: 8),
              Text('Mobile Money'),
            ],
          ),
        ),
      ],
      validator: FormBuilderValidators.required(),
    );
  }

  void _submitDonation() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final formData = _formKey.currentState!.value;
      final paymentMethod = formData['payment_method'] as String?;

      // Show custom loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const CustomLoader(
            message:
                'Processing your generous donation...\n A payment prompt will open shortly.\nPlease wait a moment.',
          );
        },
      );

      try {
        // Validate each field individually
        if (formData['name'] == null || formData['name'].isEmpty) {
          throw 'Please enter your name';
        }

        if (formData['email'] == null || formData['email'].isEmpty) {
          throw 'Please enter your email';
        }

        if (formData['phone'] == null || formData['phone'].isEmpty) {
          throw 'Please enter your phone number';
        }

        if (_selectedAmount <= 0) {
          throw 'Please select a valid donation amount';
        }

        if (paymentMethod == 'creditCard') {
          await _handleCreditCardPayment(formData);
        } else {
          await _handleMobileMoneyPayment(formData);
        }
      } catch (e) {
        print('Donation failed: $e');
        Navigator.of(context).pop(); // Dismiss the loader

        // Show error message
        _showFailureScreen(e.toString());
      }
    } else {
      // Form validation failed
      _showFailureScreen('Please fill in all required fields correctly.');
    }
  }

  Future<void> _handleCreditCardPayment(Map<String, dynamic> formData) async {
    final response = await _donationService.initiateDonationDpo(
      eid: widget.eid,
      name: formData['name'],
      email: formData['email'],
      phone: formData['phone'],
      amount: _selectedAmount.toStringAsFixed(0),
      tipAmount: _calculateTipAmount().toInt(),
    );
    html.window.location.href = response;
  }

  Future<void> _handleMobileMoneyPayment(Map<String, dynamic> formData) async {
    final provider = UgandanProviderDetector.getProvider(formData['phone']);

    if (provider == null) {
      throw 'Invalid phone number. Please enter a valid Ugandan mobile number.';
    }

    final response = await _donationService.initiateDonation(
      eid: widget.eid,
      name: formData['name'],
      email: formData['email'],
      phone: "256${formData['phone']}",
      amount: _selectedAmount.toStringAsFixed(0),
      tipAmount: _calculateTipAmount().toInt(),
      provider: provider,
    );

    _showSuccessScreen(response);
  }

  void _showSuccessScreen(String message) {
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: -pi / 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.05,
                ),
                Lottie.network(
                    'https://assets3.lottiefiles.com/packages/lf20_jbrw3hcz.json',
                    width: 200,
                    height: 200),
                const SizedBox(height: 20),
                Text(
                  'Thank You for Your Generosity!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Your donation of UGX ${_selectedAmount.toStringAsFixed(2)} will make a real difference.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFailureScreen(String errorMessage) {
    context.go(
      '/payment-failure?errorMessage=${Uri.encodeComponent(e.toString())}',
    );
  }
}

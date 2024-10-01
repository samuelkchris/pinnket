import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinnket/services/toast_service.dart';
import 'package:pinnket/utils/hider.dart';
import 'package:provider/provider.dart';

import '../../database/policy_data.dart';
import '../../models/auth_models.dart';
import '../../providers/footer_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';

class EmailOtpLoginScreen extends StatefulWidget {
  const EmailOtpLoginScreen({super.key});
  @override
  _EmailOtpLoginScreenState createState() => _EmailOtpLoginScreenState();
}

class _EmailOtpLoginScreenState extends State<EmailOtpLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(5, (_) => TextEditingController());
  bool _isOtpSent = false;
  bool _hasExistingOtp = false;
  bool _isResendActive = false;
  int _resendTimer = 30;
  Timer? _timer;
  String? _emailError;
  String? _otpError;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final ToastManager _toastManager = ToastManager();

  @override
  void initState() {
    super.initState();
    callJavaScriptMethods();
    _logPageView();
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _logPageView() {
    FirebaseService.analytics.logEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': 'EmailOtpLoginScreen',
        'screen_class': 'EmailOtpLoginScreen',
      },
    );
  }

  bool _validateEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (_validateEmail(email)) {
      setState(() {
        _isLoading = true;
        _emailError = null;
      });

      try {
        final message = await _authService.requestLoginOtp(email);
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
          _startResendTimer();
        });
        _toastManager.showSuccessToast(context, message);

        // Add this analytics event
        FirebaseService.analytics.logEvent(
          name: 'otp_sent',
          parameters: {'email': email},
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
          _emailError = e.toString();
        });

        // Add this analytics event
        FirebaseService.analytics.logEvent(
          name: 'otp_send_error',
          parameters: {'error': e.toString()},
        );
      }
    } else {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });

      // Add this analytics event
      FirebaseService.analytics.logEvent(
        name: 'invalid_email_attempt',
        parameters: {'email': email},
      );
    }
  }

  Future<void> _verifyOtp() async {
    String otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length == 5) {
      setState(() {
        _isLoading = true;
        _otpError = null;
      });

      try {
        final LoginResponse response =
        await _authService.login(_emailController.text.trim(), otp);

        // Update UserProvider with the new login data
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.setLoginResponse(
            response, _emailController.text.trim());
        userProvider.setOtp(otp);

        _toastManager.showSuccessToast(context, response.message);

        // Add this analytics event
        FirebaseService.analytics.logLogin(
          loginMethod: 'email_otp',
        );

        context.go('/');
      } catch (e) {
        _toastManager.showErrorToast(context, e.toString());
        setState(() {
          _isLoading = false;
          _otpError = e.toString();
        });

        // Add this analytics event
        FirebaseService.analytics.logEvent(
          name: 'login_error',
          parameters: {'error': e.toString()},
        );
      }
    } else {
      setState(() {
        _otpError = 'Please enter a valid 5-digit OTP';
      });

      // Add this analytics event
      FirebaseService.analytics.logEvent(
        name: 'invalid_otp_attempt',
        parameters: {'otp_length': otp.length},
      );
    }
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _isResendActive = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _isResendActive = true;
          timer.cancel();
        }
      });
    });
  }


  void _editEmail() {
    setState(() {
      _isOtpSent = false;
      _hasExistingOtp = false;
      _timer?.cancel();
      _isResendActive = false;
      _emailError = null;
      _otpError = null;
    });

    // Add this analytics event
    FirebaseService.analytics.logEvent(name: 'edit_email');
  }

  void _toggleExistingOtp() {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'Please enter your email address first';
      });
    } else {
      setState(() {
        _hasExistingOtp = !_hasExistingOtp;
        _emailError = null;
      });

      // Add this analytics event
      FirebaseService.analytics.logEvent(
        name: 'toggle_existing_otp',
        parameters: {'has_existing_otp': _hasExistingOtp},
      );
    }
  }


  void _openPolicy(
      String policyName, String setSelectedDoc, int setSelectedNavItem) {
    final provider = Provider.of<FooterStateModel>(context, listen: false);
    provider.setSelectedDoc(setSelectedDoc);
    provider.setSelectedNavItem(setSelectedNavItem);
    provider.setTitle('Reference');

    // Add this analytics event
    FirebaseService.analytics.logEvent(
      name: 'view_policy',
      parameters: {'policy_name': policyName},
    );

    context.go('/reference');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1200) {
            return _buildWideLayout(context);
          } else if (constraints.maxWidth > 800) {
            return _buildMediumLayout(context);
          } else {
            return _buildNarrowLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildImageSection(context),
        ),
        Expanded(
          flex: 3,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: _buildCard(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediumLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildImageSection(context),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _buildCard(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/boy.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogo(context),
                  const SizedBox(height: 48),
                  _buildCard(context),
                  const SizedBox(height: 16),
                  _buildPolicyAgreement(context),
                  const SizedBox(height: 24),
                  _buildCopyright(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/boy.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: _buildLogo(context),
              ),
              const SizedBox(height: 48),
              Text(
                'Beyond Tickets, Beyond Ordinary',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Image.asset(
                  "assets/images/elevateTransparent2.png",
                  // Add your large image asset here
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 48),
              _buildPolicyAgreement(context),
              const SizedBox(height: 24),
              _buildCopyright(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 160,
      height: 140,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Image.asset(
        "assets/images/sc.png",
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitle(context),
            const SizedBox(height: 8),
            _buildSubtitle(context),
            const SizedBox(height: 32),
            _buildEmailInput(context),
            if (_isOtpSent || _hasExistingOtp) ...[
              const SizedBox(height: 24),
              _buildOtpInput(context),
              if (_otpError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _otpError!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              const SizedBox(height: 24),
              _buildVerifyOtpButton(context),
              if (_isOtpSent) ...[
                const SizedBox(height: 16),
                _buildResendOtpButton(context),
              ],
              const SizedBox(height: 16),
              _buildEditEmailButton(context),
            ] else ...[
              const SizedBox(height: 24),
              _buildSendOtpButton(context),
              const SizedBox(height: 16),
              _buildHaveOtpToggle(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      _isOtpSent || _hasExistingOtp ? 'Enter OTP' : 'Welcome Back',
      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      _isOtpSent || _hasExistingOtp
          ? 'Enter the 6-digit code sent to your email'
          : 'Sign in with your email address',
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailInput(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Iconsax.sms),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        errorText: _emailError,
        enabled: !_isOtpSent && !_hasExistingOtp,
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildSendOtpButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading
          ? null
          : () {
        FirebaseService.analytics.logEvent(name: 'send_otp_button_click');
        _sendOtp();
      },
      icon: _isLoading
          ? const CircularProgressIndicator()
          : const Icon(Iconsax.send_1),
      label: Text(_isLoading ? 'Sending...' : ' | Send OTP'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildVerifyOtpButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading
          ? null
          : () {
        FirebaseService.analytics.logEvent(name: 'verify_otp_button_click');
        _verifyOtp();
      },
      icon: _isLoading
          ? const CircularProgressIndicator()
          : const Icon(Iconsax.tick_circle),
      label: Text(_isLoading ? 'Verifying...' : ' | Verify OTP'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildHaveOtpToggle(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        FirebaseService.analytics.logEvent(name: 'have_otp_toggle_click');
        _toggleExistingOtp();
      },
      icon: const Icon(Iconsax.key),
      label: const Text(' | I already have an OTP'),
    );
  }



  Widget _buildOtpInput(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = (constraints.maxWidth - 40) / 5;
        final fontSize = boxWidth * 0.5;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              5,
              (index) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                width: boxWidth,
                child: TextFormField(
                  controller: _otpControllers[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyle(fontSize: fontSize),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: EdgeInsets.zero,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 4) {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResendOtpButton(BuildContext context) {
    return TextButton.icon(
      onPressed: _isResendActive ? _sendOtp : null,
      icon: const Icon(Iconsax.refresh),
      label: Text(
          _isResendActive ? ' | Resend OTP' : ' | Resend in $_resendTimer s'),
    );
  }

  Widget _buildEditEmailButton(BuildContext context) {
    return TextButton.icon(
      onPressed: _editEmail,
      icon: const Icon(Iconsax.edit),
      label: const Text(' | Edit Email'),
    );
  }

  Widget _buildPolicyAgreement(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .copyWith(color: Colors.white),
        children: [
          const TextSpan(text: 'By using this PinnKET, you agree to our '),
          TextSpan(
            text: 'Terms and Conditions',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
            recognizer: TapGestureRecognizer()
              ..onTap =
                  () => _openPolicy('Terms and Conditions', termsOfUse, 3),
          ),
          const TextSpan(text: ', '),
          TextSpan(
            text: 'Privacy Policy',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _openPolicy('Privacy Policy', privacyPolicy, 7),
          ),
          const TextSpan(text: ', and '),
          TextSpan(
            text: 'Cookie Policy',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => _openPolicy('Cookie Policy', cookiePolicy, 6),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Text(
      '© 2024 PinnKET. All rights reserved.',
      style:
          Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
      textAlign: TextAlign.center,
    );
  }
}

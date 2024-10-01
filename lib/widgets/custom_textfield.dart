import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:country_currency_pickers/country_pickers.dart';
import 'package:country_currency_pickers/utils/utils.dart';

class CustomAmountField extends StatelessWidget {
  final String name;
  final String label;
  final String? hintText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final List<String>? autofillHints;
  final ValueChanged<String?>? onChanged;
  final GestureTapCallback? onTap;
  final ValueChanged<String?>? onSubmitted;
  final GestureTapCallback? onEditingComplete;

  const CustomAmountField({
    super.key,
    required this.name,
    required this.label,
    this.hintText,
    this.maxLength,
    this.inputFormatters,
    this.autofillHints,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final country = CountryPickerUtils.getCountryByIsoCode('UG');
    final currencySymbol = country.currencyCode;

    return FormBuilderTextField(
      name: name,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
        FormBuilderValidators.numeric(),
      ]),
      onTap: onTap,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      maxLength: maxLength,
      inputFormatters:
          inputFormatters ?? [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CountryPickerUtils.getDefaultFlagImage(country),
              const SizedBox(width: 8),
              Text(currencySymbol!,
                  style: TextStyle(color: theme.colorScheme.primary)),
            ],
          ),
        ),
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
      keyboardType: TextInputType.number,
      autofillHints: autofillHints,
      style: TextStyle(color: theme.colorScheme.onSurface),
    );
  }
}

class CustomPhoneField extends StatelessWidget {
  final String name;
  final String label;
  final String? hintText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final List<String>? autofillHints;

  const CustomPhoneField({
    super.key,
    required this.name,
    required this.label,
    this.hintText,
    this.maxLength,
    this.inputFormatters,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final country = CountryPickerUtils.getCountryByIsoCode('UG');
    final dialCode = country.phoneCode;

    return FormBuilderTextField(
      name: name,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
        FormBuilderValidators.numeric(),
        FormBuilderValidators.minLength(9),
        FormBuilderValidators.maxLength(9),
      ]),
      maxLength: maxLength ?? 9,
      inputFormatters:
          inputFormatters ?? [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CountryPickerUtils.getDefaultFlagImage(country),
              const SizedBox(width: 8),
              Text('+$dialCode',
                  style: TextStyle(color: theme.colorScheme.primary)),
            ],
          ),
        ),
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
      keyboardType: TextInputType.phone,
      autofillHints: autofillHints ?? [AutofillHints.telephoneNumber],
      style: TextStyle(color: theme.colorScheme.onSurface),
    );
  }
}

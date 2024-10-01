class UgandanProviderDetector {
  static String? getProvider(String number) {
    String sanitizedNumber = number.replaceFirst(RegExp(r'^0'), '');

    if (sanitizedNumber.startsWith('256')) {
      sanitizedNumber = sanitizedNumber.substring(3);
    }

    RegExp mtnRegExp = RegExp(r'^(31|39|77|78)\d{7}$');
    RegExp airtelRegExp = RegExp(r'^(70|75|20)\d{7}$');

    if (mtnRegExp.hasMatch(sanitizedNumber)) {
      return 'MTN_UGANDA';
    } else if (airtelRegExp.hasMatch(sanitizedNumber)) {
      return 'AIRTEL_UGANDA';
    } else {
      return null;
    }
  }
}

String sanitizePhoneNumber(String phoneNumber) {
  if (phoneNumber.startsWith('0')) {
    return '256${phoneNumber.substring(1)}';
  } else if (!phoneNumber.startsWith('256')) {
    return '256$phoneNumber';
  }
  return phoneNumber;
}

// class FormBuilderValidators {
//   static String? Function(String?) required({String? errorText}) {
//     return (value) => value == null || value.isEmpty ? errorText : null;
//   }
//
//   static String? Function(String?) email({String? errorText}) {
//     return (value) =>
//         value != null && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)
//             ? errorText
//             : null;
//   }
//
//   static String? Function(String?) minLength(int minLength,
//       {String? errorText}) {
//     return (value) =>
//         value != null && value.length < minLength ? errorText : null;
//   }
//
//   static String? Function(String?) maxLength(int maxLength,
//       {String? errorText}) {
//     return (value) =>
//         value != null && value.length > maxLength ? errorText : null;
//   }
//
//   static String? Function(String?) match(String pattern, {String? errorText}) {
//     return (value) =>
//         value != null && !RegExp(pattern).hasMatch(value) ? errorText : null;
//   }
//
//   static compose(List<String? Function(String? p1)> list) {
//     return (String? value) {
//       for (var validator in list) {
//         final error = validator(value);
//         if (error != null) {
//           return error;
//         }
//       }
//       return null;
//     };
//   }
// }

/// Professional Form Validation Utilities
class FormValidators {
  static String? required(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'This field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? minLength(String? value, int length) {
    if (value == null || value.isEmpty) return null;
    if (value.length < length) {
      return 'Must be at least $length characters';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';

    // Add more complexity checks if needed
    // bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    // bool hasDigits = value.contains(RegExp(r'[0-9]'));
    // bool hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return null;
  }
}

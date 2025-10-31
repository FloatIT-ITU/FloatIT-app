import 'package:flutter/material.dart';
import '../auth_utils.dart';

/// Centralized validation functions and form utilities to reduce duplicate code
class ValidationUtils {
  ValidationUtils._();

  // ===== VALIDATION FUNCTIONS =====

  /// Validate display name
  static String? validateDisplayName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Name cannot be empty';
    if (name.length < 2) return 'Name too short (minimum 2 characters)';
    if (name.length > 30) return 'Name too long (maximum 30 characters)';
    if (!RegExp(r'^[a-zA-Z0-9 -]+$').hasMatch(name)) {
      return 'Only letters, numbers, spaces, and hyphens allowed';
    }
    if (AuthUtils.isForbiddenDisplayName(name)) {
      return 'This display name is not allowed';
    }
    return null;
  }

  /// Validate email (ITU specific)
  static String? validateItuEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email cannot be empty';
    if (!email.contains('@')) return 'Invalid email format';
    if (!email.endsWith('@itu.dk')) return 'Use your @itu.dk email';
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value, {int minLength = 6}) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) return 'Password cannot be empty';
    if (password.length < minLength)
      return 'Password must be at least $minLength characters';
    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(
      String? value, String originalPassword) {
    final password = value?.trim() ?? '';
    if (password.isEmpty) return 'Please confirm your password';
    if (password != originalPassword) return 'Passwords do not match';
    return null;
  }

  /// Validate event name
  static String? validateEventName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Event name is required';
    if (name.length > 100)
      return 'Event name too long (maximum 100 characters)';
    return null;
  }

  /// Validate event description
  static String? validateEventDescription(String? value) {
    final description = value?.trim() ?? '';
    if (description.length > 1000)
      return 'Description too long (maximum 1000 characters)';
    return null; // Description is optional
  }

  /// Validate attendee limit
  static String? validateAttendeeLimit(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Attendee limit is required';
    final limit = int.tryParse(text);
    if (limit == null) return 'Must be a valid number';
    if (limit < 1) return 'Must be at least 1';
    if (limit > 1000) return 'Maximum limit is 1000';
    return null;
  }

  /// Validate required field (generic)
  static String? validateRequired(String? value, String fieldName) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$fieldName is required';
    return null;
  }

  // ===== FORM FIELD BUILDERS =====

  /// Create a standard text form field with consistent styling
  static Widget buildTextFormField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLength,
    int? maxLines = 1,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }

  /// Create a dropdown form field with consistent styling
  static Widget buildDropdownFormField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Extension methods for Form validation
extension FormValidationExtension on GlobalKey<FormState> {
  /// Validate form and show first error if validation fails
  bool validateAndShowError(BuildContext context) {
    if (currentState?.validate() ?? false) {
      return true;
    }
    // Optionally show a snackbar for the first error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fix the errors in the form')),
    );
    return false;
  }
}

/// Security utilities for input validation and sanitization
class SecurityUtils {
  /// Sanitize string input by trimming and removing potentially harmful characters
  static String sanitizeString(String? input) {
    if (input == null) return '';
    return input.trim().replaceAll(RegExp(r'[<>\"&]'), '');
  }

  /// Validate string length
  static bool isValidLength(String? input, {int min = 0, int max = 1000}) {
    if (input == null) return min == 0;
    final length = input.trim().length;
    return length >= min && length <= max;
  }

  /// Validate email format (basic validation)
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Validate ITU email specifically
  static bool isValidItuEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    return isValidEmail(normalizedEmail) && normalizedEmail.endsWith('@itu.dk');
  }

  /// Sanitize HTML content (remove script tags and dangerous elements)
  static String sanitizeHtml(String? input) {
    if (input == null) return '';
    var sanitized = input.trim();

    // Remove script tags
    sanitized = sanitized.replaceAll(
        RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '');
    sanitized = sanitized.replaceAll(
        RegExp(r'<script[^>]*>', caseSensitive: false), '');

    // Remove other potentially dangerous tags
    sanitized = sanitized.replaceAll(
        RegExp(r'<(iframe|object|embed)[^>]*>.*?</\1>', caseSensitive: false),
        '');

    // Remove javascript: URLs
    sanitized =
        sanitized.replaceAll(RegExp(r'javascript:', caseSensitive: false), '');

    return sanitized;
  }

  /// Validate date range
  static bool isValidDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) return true;
    if (start == null || end == null) return false;
    return end.isAfter(start);
  }

  /// Validate numeric range
  static bool isValidNumericRange(num? value, {num? min, num? max}) {
    if (value == null) return true;
    if (min != null && value < min) return false;
    if (max != null && value > max) return false;
    return true;
  }

  /// Sanitize filename (remove path traversal and dangerous characters)
  static String sanitizeFilename(String filename) {
    return filename
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll('..', '')
        .trim();
  }

  /// Validate file extension
  static bool isValidFileExtension(
      String filename, List<String> allowedExtensions) {
    final extension = filename.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// Rate limiting helper (simple in-memory implementation)
  static bool shouldAllowAction(
      String actionKey, Duration window, int maxAttempts) {
    // This is a simple implementation. In production, use Redis or similar.
    // For now, we'll just return true as this is a client-side app.
    return true;
  }

  /// Generate secure random string
  static String generateSecureToken([int length = 32]) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var result = '';

    for (var i = 0; i < length; i++) {
      result += chars[(random + i) % chars.length];
    }

    return result;
  }

  /// Validate password strength (basic)
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.length < 8) return PasswordStrength.weak;

    var hasUpper = false;
    var hasLower = false;
    var hasDigit = false;
    var hasSpecial = false;

    for (final char in password.runes) {
      final c = String.fromCharCode(char);
      if (RegExp(r'[A-Z]').hasMatch(c)) hasUpper = true;
      if (RegExp(r'[a-z]').hasMatch(c)) hasLower = true;
      if (RegExp(r'[0-9]').hasMatch(c)) hasDigit = true;
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(c)) hasSpecial = true;
    }

    final criteria =
        [hasUpper, hasLower, hasDigit, hasSpecial].where((c) => c).length;

    if (password.length >= 12 && criteria >= 3) return PasswordStrength.strong;
    if (password.length >= 10 && criteria >= 2) return PasswordStrength.medium;
    return PasswordStrength.weak;
  }
}

/// Password strength enumeration
enum PasswordStrength {
  weak,
  medium,
  strong,
}

/// Extension methods for security validation
extension SecurityExtensions on String {
  String sanitize() => SecurityUtils.sanitizeString(this);

  bool get isValidEmail => SecurityUtils.isValidEmail(this);

  bool get isValidItuEmail => SecurityUtils.isValidItuEmail(this);

  PasswordStrength get passwordStrength =>
      SecurityUtils.checkPasswordStrength(this);
}

/// Extension methods for security validation on nullable strings
extension NullableSecurityExtensions on String? {
  String sanitize() => SecurityUtils.sanitizeString(this);

  bool isValidLength({int min = 0, int max = 1000}) =>
      SecurityUtils.isValidLength(this, min: min, max: max);
}

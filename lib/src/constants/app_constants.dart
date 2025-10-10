/// Application-wide constants organized by category
library constants;

// ===== LAYOUT CONSTANTS =====

/// Maximum width for page content
const double kContentMaxWidth = 720.0;

/// Standard padding values
class Paddings {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Standard spacing values
class Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

/// Border radius values
class BorderRadii {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double circle = 999.0;
}

// ===== ANIMATION CONSTANTS =====

/// Animation duration values
class AnimationDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

// ===== VALIDATION CONSTANTS =====

/// Validation limits and rules
class ValidationLimits {
  static const int displayNameMinLength = 2;
  static const int displayNameMaxLength = 30;
  static const int passwordMinLength = 6;
  static const int eventNameMaxLength = 100;
  static const int eventDescriptionMaxLength = 1000;
  static const int attendeeLimitMin = 1;
  static const int attendeeLimitMax = 1000;
}

/// Regular expressions for validation
class ValidationRegex {
  static final RegExp displayName = RegExp(r'^[a-zA-Z0-9 ]+$');
  static final RegExp email = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  static final RegExp ituEmail = RegExp(r'^[^@]+@itu\.dk$');
}

// ===== EVENT CONSTANTS =====

/// Event types
class EventTypes {
  static const String practice = 'practice';
  static const String competition = 'competition';
  static const String other = 'other';
  
  static const List<String> all = [practice, competition, other];
}

/// Occupation types
class OccupationTypes {
  static const List<String> all = [
    'SWU',
    'GBI',
    'BDDIT',
    'BDS',
    'MDDIT',
    'DIM',
    'E-BUSS',
    'GAMES/DT',
    'GAMES/Tech',
    'CS',
    'SD',
    'MDS',
    'MIT',
    'Employee',
    'PhD',
    'Other',
  ];
}

// ===== CACHE CONSTANTS =====

/// Cache durations for different data types
class CacheDurations {
  static const Duration adminUsers = Duration(minutes: 5);
  static const Duration userProfile = Duration(minutes: 10);
  static const Duration events = Duration(minutes: 1);
}

// ===== NETWORK CONSTANTS =====

/// Timeout values for network operations
class NetworkTimeouts {
  static const Duration connection = Duration(seconds: 10);
  static const Duration request = Duration(seconds: 30);
  static const Duration upload = Duration(minutes: 2);
}

// ===== UI CONSTANTS =====

/// Icon sizes
class IconSizes {
  static const double xs = 12.0;
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Avatar sizes
class AvatarSizes {
  static const double sm = 16.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
}

/// Button sizes
class ButtonSizes {
  static const double height = 48.0;
  static const double minWidth = 100.0;
}

// ===== STRING CONSTANTS =====

/// Common error messages
class ErrorMessages {
  static const String networkError = 'Network error. Please check your connection.';
  static const String unknownError = 'An unknown error occurred. Please try again.';
  static const String authError = 'Authentication failed. Please sign in again.';
  static const String permissionDenied = 'Permission denied. Contact an admin.';
  static const String eventNotFound = 'Event not found.';
  static const String userNotFound = 'User not found.';
}

/// Success messages
class SuccessMessages {
  static const String profileUpdated = 'Profile updated successfully';
  static const String eventCreated = 'Event created successfully';
  static const String eventUpdated = 'Event updated successfully';
  static const String eventDeleted = 'Event deleted successfully';
  static const String passwordChanged = 'Password changed successfully';
  static const String emailSent = 'Email sent successfully';
}

/// Loading messages
class LoadingMessages {
  static const String loading = 'Loading...';
  static const String saving = 'Saving...';
  static const String uploading = 'Uploading...';
  static const String deleting = 'Deleting...';
  static const String sendingEmail = 'Sending email...';
}

// ===== ASSET PATHS =====

/// Asset paths for images, fonts, etc.
class AssetPaths {
  static const String privacyPolicy = 'assets/privacy_policy.md';
  static const String signupBackground = 'assets/signup_bg.jpg';
}

// ===== FIREBASE COLLECTION NAMES =====

/// Firebase collection names to ensure consistency
class Collections {
  static const String users = 'users';
  static const String publicUsers = 'public_users';
  static const String events = 'events';
  static const String app = 'app';
  static const String templates = 'templates';
}

/// Firebase document names
class Documents {
  static const String globalBanner = 'global_banner';
  static const String eventBanner = 'event_banner';
}

// ===== FEATURE FLAGS =====

/// Feature flags for enabling/disabling functionality
class FeatureFlags {
  static const bool enableNotifications = true;
  static const bool enableAnalytics = false;
  static const bool enableDebugMode = false;
}
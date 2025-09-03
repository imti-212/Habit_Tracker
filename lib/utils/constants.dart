class AppConstants {
  // App Information
  static const String appName = 'Habit Tracker';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String habitsCollection = 'habits';
  static const String favoritesCollection = 'favorites';
  static const String quotesCollection = 'quotes';
  static const String preferencesCollection = 'preferences';
  
  // Shared Preferences Keys
  static const String isLoggedInKey = 'isLoggedIn';
  static const String userEmailKey = 'userEmail';
  static const String themeModeKey = 'themeMode';
  
  // API Endpoints
  static const String quotesApiUrl = 'https://api.quotable.io/quotes/random';
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxHabitTitleLength = 100;
  static const int maxHabitNotesLength = 200;
  static const int maxDisplayNameLength = 50;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}

class HabitCategories {
  static const Map<String, String> displayNames = {
    'health': 'Health',
    'study': 'Study',
    'fitness': 'Fitness',
    'productivity': 'Productivity',
    'mentalHealth': 'Mental Health',
    'others': 'Others',
  };
  
  static const Map<String, String> descriptions = {
    'health': 'Health and wellness related habits',
    'study': 'Learning and educational habits',
    'fitness': 'Physical exercise and fitness habits',
    'productivity': 'Work and productivity habits',
    'mentalHealth': 'Mental health and mindfulness habits',
    'others': 'Other miscellaneous habits',
  };
}

class ErrorMessages {
  static const String networkError = 'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String generalError = 'Something went wrong. Please try again.';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String weakPassword = 'Password is too weak.';
  static const String emailInUse = 'Email is already in use.';
  static const String userNotFound = 'User not found.';
  static const String wrongPassword = 'Incorrect password.';
}

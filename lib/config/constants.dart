class AppConstants {
  // App information
  static const String appName = 'NotifyHub';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A digital notice board application';
  
  // Routes
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeNoticeDetail = '/notice-detail';
  static const String routeCreateNotice = '/create-notice';
  static const String routeEditNotice = '/edit-notice';
  static const String routeAdminDashboard = '/admin-dashboard';
  static const String routeAdminManagement = '/admin-management'; // New route
  static const String routeUserProfile = '/user-profile';
  
  // Firestore collections
  static const String collectionUsers = 'users';
  static const String collectionNotices = 'notices';
  static const String collectionComments = 'comments';
  static const String collectionNotifications = 'notifications'; // For notification system
  
  // Firebase Storage paths
  static const String storagePath = 'notifyhub';
  
  // FCM topics
  static const String topicAllUsers = 'all_users';
  static const String topicImportant = 'important_notices';
  
  // Pagination
  static const int noticesPerPage = 10;
  static const int commentsPerPage = 20;
  
  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // Shared preferences keys
  static const String prefDarkMode = 'dark_mode';
  static const String prefNotifications = 'notifications_enabled';
  static const String prefFcmToken = 'fcm_token';
  static const String prefFirstLaunch = 'first_launch';
  static const String prefLastRefreshed = 'last_refreshed';
  
  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 10);
  static const Duration cacheExpiration = Duration(hours: 1);
  
  // Error messages
  static const String errorGeneric = 'An error occurred. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorPermission = 'You do not have permission to perform this action.';
  static const String errorLogin = 'Invalid email or password.';
  static const String errorSignup = 'Failed to create account. Try again.';
  
  // Success messages
  static const String successNoticeCreated = 'Notice created successfully.';
  static const String successNoticeUpdated = 'Notice updated successfully.';
  static const String successNoticeDeleted = 'Notice deleted successfully.';
  static const String successCommentAdded = 'Comment added successfully.';
  static const String successAdminAdded = 'User promoted to admin successfully.';
  static const String successAdminRemoved = 'Admin rights removed successfully.';
  
  // Tags for filtering
  static const List<String> defaultTags = [
    'Announcement',
    'Event',
    'Academic',
    'Administrative',
    'Sports',
    'Cultural',
    'Placement',
    'Exam',
    'Holiday',
    'Other'
  ];
}
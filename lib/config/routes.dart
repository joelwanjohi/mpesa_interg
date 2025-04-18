import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/notices/notice_list.dart';
import '../screens/notices/notice_detail.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/create_notice.dart';
import '../screens/admin/edit_notice.dart';
import '../screens/admin/admin_management.dart'; // New import
import 'constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeHome:
        return MaterialPageRoute(builder: (_) => const NoticeListScreen());
        
      case AppConstants.routeLogin:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        
      case AppConstants.routeSignup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
        
      case AppConstants.routeNoticeDetail:
        final noticeId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => NoticeDetailScreen(noticeId: noticeId),
        );
        
      case AppConstants.routeCreateNotice:
        return MaterialPageRoute(builder: (_) => const CreateNoticeScreen());
        
      case AppConstants.routeEditNotice:
        final noticeId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditNoticeScreen(noticeId: noticeId),
        );
        
      case AppConstants.routeAdminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      
      case AppConstants.routeAdminManagement: // New route
        return MaterialPageRoute(builder: (_) => const AdminManagementScreen());
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
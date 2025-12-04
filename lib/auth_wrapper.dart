import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> _checkLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final hasToken = prefs.getString('twitter_token') != null;
    
    print('🔍 AuthWrapper - Checking local session:');
    print('   is_logged_in: $isLoggedIn');
    print('   has_token: $hasToken');
    print('   username: ${prefs.getString('twitter_username')}');
    
    return isLoggedIn && hasToken;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLocalSession(),
      builder: (context, snapshot) {
        print('\n=== AUTH WRAPPER ===');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final hasLocalSession = snapshot.data ?? false;
        print('Has local session: $hasLocalSession');
        
        if (hasLocalSession) {
          // Get user info from SharedPreferences
          return FutureBuilder<Map<String, String?>>(
            future: _getUserInfo(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              final userInfo = userSnapshot.data ?? {};
              final username = userInfo['username'] ?? 'User';
              
              print('✅ Welcome back, $username!');
              
              return DashboardScreen(
                userName: username,
                profileImage: userInfo['profileImage'],
              );
            },
          );
        }
        
        print('❌ No session found - showing login');
        return const LoginScreen();
      },
    );
  }
  
  Future<Map<String, String?>> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('twitter_username'),
      'profileImage': null,
    };
  }
}
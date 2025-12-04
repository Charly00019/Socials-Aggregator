import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
  final String backendBase = "http://10.0.2.2:5000";

  Future<void> _signInWithTwitter() async {
    print('🚀 === STARTING TWITTER AUTH ===');
    setState(() => loading = true);

    try {
      // Use EXACT same redirect URI as AndroidManifest
      final twitterLogin = TwitterLogin(
        apiKey: dotenv.env['TWITTER_API_KEY'] ?? '',
        apiSecretKey: dotenv.env['TWITTER_API_SECRET'] ?? '',
        redirectURI: 'com.socials.app://callback',
      );

      print('🔗 AndroidManifest expects: com.socials.app://callback');
      print('🔗 Using redirect URI: ${twitterLogin.redirectURI}');

      // Start Twitter OAuth
      print('🔄 Opening Twitter OAuth...');
      final authResult = await twitterLogin.login();
      
      print('📱 Twitter login result: ${authResult.status}');

      if (authResult.status == TwitterLoginStatus.loggedIn) {
        print('✅ Twitter OAuth SUCCESS!');
        
        final accessToken = authResult.authToken!;
        final secret = authResult.authTokenSecret!;
        final twitterUser = authResult.user;
        
        print('👤 Twitter username: ${twitterUser?.name}');
        print('🆔 Twitter ID: ${twitterUser?.id}');
        print('📧 Twitter email: ${twitterUser?.email}');

        // 🎯 FIX: Convert all values to String
        final userId = twitterUser?.id?.toString() ?? '';
        final username = twitterUser?.name?.toString() ?? 'User';
        final email = twitterUser?.email?.toString();

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('twitter_token', accessToken);
        await prefs.setString('twitter_secret', secret);
        await prefs.setString('twitter_user_id', userId); // Now a String
        await prefs.setString('twitter_username', username); // Now a String
        if (email != null) {
          await prefs.setString('twitter_email', email);
        }
        await prefs.setBool('is_logged_in', true);
        print('💾 Saved to SharedPreferences');

        // Try Firebase (optional)
        try {
          print('🔥 Attempting Firebase auth...');
          final credential = TwitterAuthProvider.credential(
            accessToken: accessToken,
            secret: secret,
          );
          
          await FirebaseAuth.instance.signInWithCredential(credential);
          print('✅ Firebase auth successful');
        } catch (firebaseError) {
          print('⚠️ Firebase auth failed (using local): $firebaseError');
        }

        // Send to backend (optional)
        try {
          print('📡 Sending to backend...');
          final response = await http.post(
            Uri.parse("$backendBase/api/link-twitter"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'oauthToken': accessToken,
              'oauthSecret': secret,
              'twitterUserId': userId,
              'username': username,
              'email': email,
            }),
          );
          print('📡 Backend response: ${response.statusCode}');
        } catch (e) {
          print('⚠️ Backend error: $e');
        }

        // Navigate IMMEDIATELY
        print('📍 Navigating to Dashboard...');
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userName: username,
                profileImage: twitterUser?.thumbnailImage?.toString(),
              ),
            ),
            (route) => false,
          );
        });

      } else {
        print('❌ Twitter auth failed: ${authResult.errorMessage}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Twitter error: ${authResult.errorMessage ?? "Unknown"}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stack) {
      print('❌ ERROR: $e');
      print('Stack: $stack');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
      print('=== PROCESS COMPLETED ===');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login with Twitter")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Redirecting after Twitter login...'),
                ],
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text("Sign in with Twitter"),
                onPressed: _signInWithTwitter,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
              ),
            
            const SizedBox(height: 40),
            
            // Debug button
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                print('=== SESSION CHECK ===');
                print('is_logged_in: ${prefs.getBool('is_logged_in')}');
                print('twitter_username: ${prefs.getString('twitter_username')}');
                print('twitter_user_id: ${prefs.getString('twitter_user_id')}');
                print('Firebase user: ${FirebaseAuth.instance.currentUser?.uid}');
              },
              child: const Text('Check Session'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await FirebaseAuth.instance.signOut();
                print('✅ Cleared all storage');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cleared storage')),
                );
              },
              child: const Text('Clear Storage'),
            ),
          ],
        ),
      ),
    );
  }
}
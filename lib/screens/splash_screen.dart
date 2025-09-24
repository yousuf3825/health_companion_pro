import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Check if user is already authenticated
      if (AuthService.isSignedIn) {
        // User is signed in, initialize app state and go to dashboard
        final appState = Provider.of<AppState>(context, listen: false);
        await appState.initializeUser();
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // Check for local user data
        Map<String, String?> localData = await AuthService.loadUserDataLocally();
        
        if (localData.isNotEmpty && localData['userId'] != null) {
          // Set app state from local data and go to dashboard
          final appState = Provider.of<AppState>(context, listen: false);
          appState.setUserId(localData['userId']!);
          appState.setRole(localData['userRole'] == 'doctor' ? UserRole.doctor : UserRole.pharmacy);
          if (localData['userName'] != null) {
            appState.setUserName(localData['userName']!);
          }
          if (localData['pharmacyName'] != null) {
            appState.setPharmacyName(localData['pharmacyName']!);
          }
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          // No user data, go to sign-in page
          Navigator.pushReplacementNamed(context, '/signin');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medical_services,
                size: 60,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 32),
            // App Name
            Text(
              'MedConnect Pro',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Connecting Doctors & Pharmacists',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 60),
            // Loading Indicator
            CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}

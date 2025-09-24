import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/registration_verification_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/doctor/slot_setup_screen.dart';
import 'screens/doctor/schedule_screen.dart';
import 'screens/doctor/join_call_screen.dart';
import 'screens/doctor/prescription_screen.dart';
import 'screens/pharmacy/incoming_prescriptions_screen.dart';
import 'screens/pharmacy/medicine_availability_screen.dart';
import 'screens/pharmacy/orders_deliveries_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notification_screen.dart';
import 'services/firebase_service.dart';
import 'models/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await FirebaseService.initialize();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(const MedConnectProApp());
}

class MedConnectProApp extends StatelessWidget {
  const MedConnectProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'MedConnect Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/signin': (context) => const SignInScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/role-selection': (context) => const RoleSelectionScreen(),
          '/registration': (context) => const RegistrationVerificationScreen(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/notifications': (context) => const NotificationScreen(),
          '/slot-setup': (context) => const SlotSetupScreen(),
          '/schedule': (context) => const ScheduleScreen(),
          '/join-call': (context) => const JoinCallScreen(),
          '/prescription': (context) => const PrescriptionScreen(),
          '/incoming-prescriptions':
              (context) => const IncomingPrescriptionsScreen(),
          '/medicine-availability':
              (context) => const MedicineAvailabilityScreen(),
          '/orders-deliveries': (context) => const OrdersDeliveriesScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}



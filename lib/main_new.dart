import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
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

void main() {
  runApp(const SehatLinkProApp());
}

class SehatLinkProApp extends StatelessWidget {
  const SehatLinkProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SehatLink Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardTheme(
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
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/registration': (context) => const RegistrationVerificationScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
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
    );
  }
}

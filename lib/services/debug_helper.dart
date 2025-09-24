import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class DebugHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check user data consistency between Auth and Firestore
  static Future<void> checkUserDataConsistency() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('DEBUG: No authenticated user found');
        return;
      }

      print('DEBUG: Authenticated user: ${currentUser.uid}');
      print('DEBUG: User email: ${currentUser.email}');
      
      // Check users collection
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      print('DEBUG: User document exists in users collection: ${userDoc.exists}');
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        print('DEBUG: User data: $userData');
        
        String role = userData['role'] ?? 'unknown';
        String collection = role == 'doctor' ? 'doctors' : 'pharmacies';
        
        DocumentSnapshot profileDoc = await _firestore.collection(collection).doc(currentUser.uid).get();
        print('DEBUG: Profile document exists in $collection collection: ${profileDoc.exists}');
        
        if (profileDoc.exists) {
          Map<String, dynamic> profileData = profileDoc.data() as Map<String, dynamic>;
          print('DEBUG: Profile data: $profileData');
        }
      } else {
        // Check doctors collection
        DocumentSnapshot doctorDoc = await _firestore.collection('doctors').doc(currentUser.uid).get();
        print('DEBUG: User document exists in doctors collection: ${doctorDoc.exists}');
        
        if (doctorDoc.exists) {
          Map<String, dynamic> doctorData = doctorDoc.data() as Map<String, dynamic>;
          print('DEBUG: Doctor data: $doctorData');
        }
        
        // Check pharmacies collection
        DocumentSnapshot pharmacyDoc = await _firestore.collection('pharmacies').doc(currentUser.uid).get();
        print('DEBUG: User document exists in pharmacies collection: ${pharmacyDoc.exists}');
        
        if (pharmacyDoc.exists) {
          Map<String, dynamic> pharmacyData = pharmacyDoc.data() as Map<String, dynamic>;
          print('DEBUG: Pharmacy data: $pharmacyData');
        }
      }

      // Check local data
      Map<String, String?> localData = await AuthService.loadUserDataLocally();
      print('DEBUG: Local data: $localData');
      
    } catch (e) {
      print('DEBUG: Error checking user data consistency: $e');
    }
  }

  /// Create missing user profile based on current authentication
  static Future<void> createMissingUserProfile({
    String? name,
    String? role,
    String? pharmacyName,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('DEBUG: No authenticated user found');
        return;
      }

      String email = currentUser.email ?? '';
      String userId = currentUser.uid;
      String userRole = role ?? 'pharmacy'; // Default to pharmacy
      String userName = name ?? (userRole == 'doctor' ? 'Doctor User' : 'Pharmacy User');
      
      Map<String, dynamic> profileData = {
        'name': userName,
        'email': email,
        'phoneNumber': '',
        'licenseNumber': '123456',
        'role': userRole,
      };

      if (userRole == 'pharmacy') {
        profileData.addAll({
          'pharmacyName': pharmacyName ?? userName,
          'ownerName': userName,
          'gstNumber': 'Not specified',
          'address': 'Not specified',
        });
      } else {
        profileData.addAll({
          'specialty': 'General Practitioner',
          'qualification': 'MBBS',
          'experience': '1 year',
          'hospital': 'Not specified',
        });
      }

      await AuthService.createUserProfile(
        userId: userId,
        role: userRole,
        userData: profileData,
      );

      await AuthService.saveUserDataLocally(userId, userRole, profileData);
      
      print('DEBUG: User profile created successfully');
      
    } catch (e) {
      print('DEBUG: Error creating user profile: $e');
    }
  }
}
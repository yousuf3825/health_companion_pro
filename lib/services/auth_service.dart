import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

// Mock UserCredential class for when we have a User but no UserCredential due to type errors
class MockUserCredential implements UserCredential {
  @override
  final User user;
  
  MockUserCredential(this.user);
  
  @override
  AdditionalUserInfo? get additionalUserInfo => null;
  
  @override
  AuthCredential? get credential => null;
}

class AuthService {
  static final FirebaseAuth _auth = FirebaseService.auth;
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  static bool get isSignedIn => _auth.currentUser != null;

  // Get current user stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String role, // 'doctor' or 'pharmacy'
    required Map<String, dynamic> profileData,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user profile in Firestore
        try {
          await createUserProfile(
            userId: result.user!.uid,
            role: role,
            userData: {
              'email': email,
              ...profileData,
            },
          );
          
          print('User profile created in Firestore');
        } catch (firestoreError) {
          print('Firestore error: $firestoreError');
          // Don't fail the entire registration if Firestore fails
          // The auth account is already created
        }

        // Save user data locally for persistence
        try {
          await _saveUserDataLocally(result.user!.uid, role, profileData);
        } catch (localError) {
          print('Local storage error: $localError');
        }
      }

      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error: ${e.code} - ${e.message}');
      // Handle specific configuration errors
      if (e.code == 'unknown' && e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
        throw FirebaseAuthException(
          code: 'configuration-error',
          message: 'Firebase configuration issue. Please add SHA-1 fingerprint to Firebase Console.',
        );
      }
      rethrow;
    } catch (e) {
      print('Sign up error: $e');
      // Check if this is a PigeonUserDetails type error
      if (e.toString().contains('PigeonUserDetails') || e.toString().contains('ListOfObject')) {
        throw FirebaseAuthException(
          code: 'type-error',
          message: 'Firebase plugin type error. Falling back to temporary registration.',
        );
      }
      rethrow;
    }
  }

  // Temporary registration method for development (bypasses Firebase Auth issues)
  static Future<bool> registerUserTemporary({
    required String email,
    required String password,
    required String role,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      // Generate a temporary user ID
      String tempUserId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Save user credentials for temporary login
      await _saveTempCredentials(email, password);
      
      // Save user data locally for persistence
      await _saveUserDataLocally(tempUserId, role, profileData);
      
      print('Temporary registration successful for $email');
      return true;
    } catch (e) {
      print('Temporary registration error: $e');
      return false;
    }
  }

  // Temporary login method for development
  static Future<bool> loginUserTemporary({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting temporary login for: $email');
      
      // Check if temp credentials match
      Map<String, String?> tempCreds = await _getTempCredentials();
      if (tempCreds['email'] == email && tempCreds['password'] == password) {
        print('Temporary login credentials matched');
        
        // Also check if we have local user data for this email
        Map<String, String?> localData = await loadUserDataLocally();
        if (localData.isNotEmpty && localData['userEmail'] == email) {
          print('Local user data found for $email');
          return true;
        } else {
          print('No local user data found, but credentials match');
          return true;
        }
      } else {
        print('Temporary login credentials did not match');
        print('Stored email: ${tempCreds['email']}, provided: $email');
        return false;
      }
    } catch (e) {
      print('Temporary login error: $e');
      return false;
    }
  }

  // Save temporary credentials
  static Future<void> _saveTempCredentials(String email, String password) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('temp_email', email);
      await prefs.setString('temp_password', password);
    } catch (e) {
      print('Save temp credentials error: $e');
    }
  }

  // Get temporary credentials
  static Future<Map<String, String?>> _getTempCredentials() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return {
        'email': prefs.getString('temp_email'),
        'password': prefs.getString('temp_password'),
      };
    } catch (e) {
      print('Get temp credentials error: $e');
      return {};
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Check if user is already authenticated to avoid the type casting error
      User? existingUser = _auth.currentUser;
      if (existingUser != null && existingUser.email == email) {
        print('User already authenticated: ${existingUser.uid}');
        
        // Load and save user profile locally
        try {
          Map<String, dynamic>? profile = await getUserProfile(existingUser.uid);
          if (profile != null) {
            print('User profile loaded from Firestore: ${profile['role']}');
            await _saveUserDataLocally(existingUser.uid, profile['role'], profile);
          } else {
            print('No profile found in Firestore for existing user: ${existingUser.uid}');
          }
        } catch (profileError) {
          print('Error loading user profile for existing user: $profileError');
        }
        
        // Return success since user is already authenticated
        return null; // Signal that auth succeeded but with type issues
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        print('Firebase sign-in successful for user: ${result.user!.uid}');
        
        // Load and save user profile locally
        try {
          Map<String, dynamic>? profile = await getUserProfile(result.user!.uid);
          if (profile != null) {
            print('User profile loaded from Firestore: ${profile['role']}');
            await _saveUserDataLocally(result.user!.uid, profile['role'], profile);
          } else {
            print('No profile found in Firestore for user: ${result.user!.uid}');
          }
        } catch (profileError) {
          print('Error loading user profile: $profileError');
          // Don't fail the login if profile loading fails
        }
      }

      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error in signIn: ${e.code} - ${e.message}');
      
      // Handle specific type errors
      if (e.message?.toLowerCase().contains('pigeonuserdetails') == true ||
          e.message?.toLowerCase().contains('listofobject') == true) {
        throw FirebaseAuthException(
          code: 'type-error',
          message: 'Firebase plugin type error. Falling back to temporary login.',
        );
      }
      
      rethrow;
    } catch (e) {
      print('General sign in error: $e');
      
      // Check if this is a type casting error but user might be authenticated
      if (e.toString().contains('PigeonUserDetails') || 
          e.toString().contains('ListOfObject') ||
          (e.toString().contains('type') && e.toString().contains('cast'))) {
        
        // Check if user got authenticated despite the error
        User? currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          print('User authenticated despite type error: ${currentUser.uid}');
          
          // Load profile and return success using a simple approach
          try {
            Map<String, dynamic>? profile = await getUserProfile(currentUser.uid);
            if (profile != null) {
              await _saveUserDataLocally(currentUser.uid, profile['role'], profile);
            }
          } catch (profileError) {
            print('Error loading profile after type error: $profileError');
          }
          
          // Instead of creating a mock, just return null but the user is authenticated
          // The caller should check _auth.currentUser
          return null; // Signal that auth succeeded but UserCredential has issues
        }
        
        throw FirebaseAuthException(
          code: 'type-error',
          message: 'Type casting error. Falling back to temporary login.',
        );
      }
      
      rethrow;
    }
  }

  // Sign up with phone number (converting to email for Firebase Auth)
  static Future<UserCredential?> signUpWithPhone({
    required String phoneNumber,
    required String password,
    required String role,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      // Use email from profileData if available, otherwise convert phone to email
      String email = profileData['email'] ?? 
          (phoneNumber.replaceAll(RegExp(r'[^0-9]'), '') + '@medconnect.com');
      
      return await signUpWithEmailAndPassword(
        email: email,
        password: password,
        role: role,
        profileData: {
          ...profileData,
          'phoneNumber': phoneNumber,
          'email': email,
        },
      );
    } catch (e) {
      print('Phone sign up error: $e');
      rethrow;
    }
  }

  // Sign in with phone number
  static Future<UserCredential?> signInWithPhone({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Convert phone to email format for demo
      String email = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '') + '@medconnect.com';
      
      return await signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Phone sign in error: $e');
      rethrow;
    }
  }

  // Create user profile based on role
  static Future<void> createUserProfile({
    required String userId,
    required String role, // 'doctor' or 'pharmacy'
    required Map<String, dynamic> userData,
  }) async {
    try {
      String collection = role == 'doctor' ? 'doctors' : 'pharmacies';
      
      // Safely extract phone number from various possible keys
      String? phoneNumber = userData['phoneNumber'] as String? ?? 
                           userData['phone'] as String? ?? 
                           userData['phoneNo'] as String?;
      
      // Create role-specific document
      Map<String, dynamic> roleSpecificData = {
        'uid': userId,
        'role': role,
        'name': userData['name'] ?? '',
        'email': userData['email'] ?? '',
        'phoneNumber': phoneNumber ?? '',
        'licenseNumber': userData['licenseNumber'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isVerified': false, // Admin verification required
      };
      
      // Add role-specific fields
      if (role == 'doctor') {
        roleSpecificData.addAll({
          'specialty': userData['specialty'] ?? 'General Practitioner',
          'qualification': userData['qualification'] ?? 'MBBS',
          'experience': userData['experience'] ?? '1 year',
          'hospital': userData['hospital'] ?? 'Not specified',
        });
      } else {
        roleSpecificData.addAll({
          'pharmacyName': userData['pharmacyName'] ?? userData['name'] ?? '',
          'ownerName': userData['ownerName'] ?? userData['name'] ?? '',
          'gstNumber': userData['gstNumber'] ?? 'Not specified',
          'address': userData['address'] ?? 'Not specified',
        });
      }

      await _firestore.collection(collection).doc(userId).set(roleSpecificData);

      // Also create in users collection for easy lookup
      Map<String, dynamic> userLookupData = {
        'uid': userId,
        'role': role,
        'name': userData['name'] ?? '',
        'email': userData['email'] ?? '',
        'phoneNumber': phoneNumber ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      await _firestore.collection('users').doc(userId).set(userLookupData);
      
      print('User profile created successfully for $userId');
    } catch (e) {
      print('Create user profile error: $e');
      throw e;
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      print('Fetching user profile for: $userId');
      
      // First check the users collection for role information
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String role = userData['role'] ?? 'doctor';
        
        print('User role found: $role');
        
        // Get detailed profile from role-specific collection
        String collection = role == 'doctor' ? 'doctors' : 'pharmacies';
        DocumentSnapshot profileDoc = await _firestore.collection(collection).doc(userId).get();
        
        if (profileDoc.exists) {
          Map<String, dynamic> profileData = profileDoc.data() as Map<String, dynamic>;
          print('Profile data retrieved successfully');
          return profileData;
        } else {
          print('No profile document found in $collection collection');
          // Return basic user data if detailed profile doesn't exist
          return userData;
        }
      } else {
        print('No user document found in users collection');
        
        // Try to find user in doctors collection
        DocumentSnapshot doctorDoc = await _firestore.collection('doctors').doc(userId).get();
        if (doctorDoc.exists) {
          print('Found user in doctors collection');
          return doctorDoc.data() as Map<String, dynamic>;
        }
        
        // Try to find user in pharmacies collection
        DocumentSnapshot pharmacyDoc = await _firestore.collection('pharmacies').doc(userId).get();
        if (pharmacyDoc.exists) {
          print('Found user in pharmacies collection');
          return pharmacyDoc.data() as Map<String, dynamic>;
        }
        
        print('User not found in any collection');
        return null;
      }
    } catch (e) {
      print('Get user profile error: $e');
      return null; // Return null instead of throwing to prevent login failures
    }
  }

  // Update user profile
  static Future<void> updateUserProfile({
    required String userId,
    required String role,
    required Map<String, dynamic> updates,
  }) async {
    try {
      String collection = role == 'doctor' ? 'doctors' : 'pharmacies';
      
      await _firestore.collection(collection).doc(userId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update user profile error: $e');
      throw e;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _clearUserDataLocally();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Save user data locally for persistence (public method)
  static Future<void> saveUserDataLocally(
    String userId,
    String role,
    Map<String, dynamic> profileData,
  ) async {
    await _saveUserDataLocally(userId, role, profileData);
  }

  // Save user data locally for persistence (private implementation)
  static Future<void> _saveUserDataLocally(
    String userId,
    String role,
    Map<String, dynamic> profileData,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      await prefs.setString('userRole', role);
      await prefs.setString('userName', profileData['name'] ?? '');
      if (role == 'pharmacy') {
        await prefs.setString('pharmacyName', profileData['pharmacyName'] ?? profileData['name'] ?? '');
      }
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', profileData['email'] ?? '');
      await prefs.setString('userPhone', profileData['phoneNumber'] ?? '');
    } catch (e) {
      print('Save local data error: $e');
    }
  }

  // Load user data locally
  static Future<Map<String, String?>> loadUserDataLocally() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      
      if (!isLoggedIn) {
        return {};
      }

      return {
        'userId': prefs.getString('userId'),
        'userRole': prefs.getString('userRole'),
        'userName': prefs.getString('userName'),
        'pharmacyName': prefs.getString('pharmacyName'),
        'userEmail': prefs.getString('userEmail'),
        'userPhone': prefs.getString('userPhone'),
      };
    } catch (e) {
      print('Load local data error: $e');
      return {};
    }
  }

  // Clear user data locally
  static Future<void> _clearUserDataLocally() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Clear local data error: $e');
    }
  }

  // Check if user data exists locally
  static Future<bool> hasLocalUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false;
    } catch (e) {
      return false;
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset password error: $e');
      throw e;
    }
  }

  // Delete account
  static Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Get user role and delete from role-specific collection
        Map<String, dynamic>? userData = await getUserProfile(user.uid);
        if (userData != null) {
          String role = userData['role'];
          String collection = role == 'doctor' ? 'doctors' : 'pharmacies';
          await _firestore.collection(collection).doc(user.uid).delete();
        }
        
        // Delete auth account
        await user.delete();
      }
    } catch (e) {
      print('Delete account error: $e');
      throw e;
    }
  }
}
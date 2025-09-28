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
          print(
            '🚀 Attempting to create Firebase profile for user: ${result.user!.uid}',
          );
          await createUserProfile(
            userId: result.user!.uid,
            role: role,
            userData: {'email': email, ...profileData},
          );

          print('✅ User profile created in Firestore successfully');
        } catch (firestoreError) {
          print('❌ Firestore error during profile creation: $firestoreError');
          print('🔍 Error details: ${firestoreError.runtimeType}');

          // Check if this is a permissions issue
          if (firestoreError.toString().contains('permission') ||
              firestoreError.toString().contains('PERMISSION_DENIED')) {
            print(
              '🚫 Firebase Security Rules might be blocking writes. Check your Firestore rules.',
            );
          }

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
      if (e.code == 'unknown' &&
          e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
        throw FirebaseAuthException(
          code: 'configuration-error',
          message:
              'Firebase configuration issue. Please add SHA-1 fingerprint to Firebase Console.',
        );
      }
      rethrow;
    } catch (e) {
      print('Sign up error: $e');
      // Check if this is a PigeonUserDetails type error
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('ListOfObject')) {
        throw FirebaseAuthException(
          code: 'type-error',
          message:
              'Firebase plugin type error. Falling back to temporary registration.',
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
  static Future<void> _saveTempCredentials(
    String email,
    String password,
  ) async {
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
          Map<String, dynamic>? profile = await getUserProfile(
            existingUser.uid,
          );
          if (profile != null) {
            print('User profile loaded from Firestore: ${profile['role']}');
            await _saveUserDataLocally(
              existingUser.uid,
              profile['role'],
              profile,
            );
          } else {
            print(
              'No profile found in Firestore for existing user: ${existingUser.uid}',
            );
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
          Map<String, dynamic>? profile = await getUserProfile(
            result.user!.uid,
          );
          if (profile != null) {
            print('User profile loaded from Firestore: ${profile['role']}');
            await _saveUserDataLocally(
              result.user!.uid,
              profile['role'],
              profile,
            );
          } else {
            print(
              'No profile found in Firestore for user: ${result.user!.uid}',
            );
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
          message:
              'Firebase plugin type error. Falling back to temporary login.',
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
            Map<String, dynamic>? profile = await getUserProfile(
              currentUser.uid,
            );
            if (profile != null) {
              await _saveUserDataLocally(
                currentUser.uid,
                profile['role'],
                profile,
              );
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
      String email =
          profileData['email'] ??
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
      String email =
          phoneNumber.replaceAll(RegExp(r'[^0-9]'), '') + '@medconnect.com';

      return await signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Phone sign in error: $e');
      rethrow;
    }
  }

  // Create user profile based on role
  static Future<void> createUserProfile({
    required String userId,
    required String role,
    required Map<String, dynamic> userData,
  }) async {
    try {
      print('🚀 Starting createUserProfile for user: $userId, role: $role');

      // Test Firebase connection first
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      print('🔥 Firebase Firestore instance created');

      // Add timestamp and user ID to profile data
      final profileData = {
        ...userData,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isVerified': false,
        'isActive': true,
      };

      print('💾 Profile data prepared: ${profileData.keys.toList()}');
      // Create user document directly in doctors or pharmacies collection
      // Expect role to be the exact collection name: 'doctors' or 'pharmacies'
      String collectionPath = role;
      print('📍 Target collection path: $collectionPath');

      DocumentReference docRef = firestore
          .collection(collectionPath)
          .doc(userId);

      await docRef.set(profileData);
      print('✅ Document created at: ${docRef.path}');

      // Verify the document was created (top-level collection only)
      await _verifyDocumentCreation(userId, collectionPath);

      print('🎉 User profile created successfully in $collectionPath!');
    } catch (e) {
      print('❌ Error creating user profile: $e');
      print('❌ Error type: ${e.runtimeType}');
      if (e is FirebaseException) {
        print('❌ Firebase error code: ${e.code}');
        print('❌ Firebase error message: ${e.message}');
      }
      rethrow;
    }
  }

  // Update existing user profile document (merges with existing data)
  static Future<void> updateUserProfileData({
    required String userId,
    required String role,
    required Map<String, dynamic> additionalData,
  }) async {
    try {
      print('🚀 Updating user profile in /$role collection');
      print('📍 Target collection path: $role'); // Changed this line

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Add timestamp for update tracking
      final updateData = {
        ...additionalData,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save directly to /{role} collection (e.g., /doctors/userId)
      // Use set with merge to avoid failures if the document doesn't exist yet
      await firestore
          .collection(role)
          .doc(userId)
          .set(updateData, SetOptions(merge: true));

      print('✅ Successfully updated profile in /$role/$userId');
    } catch (e) {
      print('❌ Error updating profile in /$role collection: $e');
      rethrow;
    }
  }

  // Verify that the document was actually created in Firebase
  static Future<void> _verifyDocumentCreation(
    String userId,
    String role,
  ) async {
    try {
      print('🔍 Verifying document creation for $userId...');
      // role here should already be the collection name: 'doctors' or 'pharmacies'
      final doc = await _firestore.collection(role).doc(userId).get();
      print('✅ Verification: ($role/$userId) exists = ${doc.exists}');
      if (!doc.exists) {
        print('⚠️ Document not found at $role/$userId');
      }
    } catch (e) {
      print('❌ Verification failed: $e');
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      print('Fetching user profile for: $userId');

      // Prefer top-level collections first (new structure)
      DocumentSnapshot doctorDoc = await _firestore
          .collection('doctors')
          .doc(userId)
          .get();
      if (doctorDoc.exists) {
        print('Found profile in /doctors');
        return doctorDoc.data() as Map<String, dynamic>;
      }

      DocumentSnapshot pharmacyDoc = await _firestore
          .collection('pharmacies')
          .doc(userId)
          .get();
      if (pharmacyDoc.exists) {
        print('Found profile in /pharmacies');
        return pharmacyDoc.data() as Map<String, dynamic>;
      }

      // Fallback: old users collection lookup (may not exist)
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        print('Found basic user doc in /users');
        return userData;
      }

      print('User not found in any collection');
      return null;
    } catch (e) {
      print('Get user profile error: $e');
      return null; // Return null instead of throwing to prevent login failures
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile({
    required String userId,
    required String role,
    required Map<String, dynamic> updates,
  }) async {
    try {
      // Add timestamp
      Map<String, dynamic> updateData = {
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update in new structure (users/doctors or users/pharmacies)
      String roleCollection = role == 'doctor' ? 'doctors' : 'pharmacies';
      await _firestore
          .collection('users')
          .doc(roleCollection)
          .collection('profiles')
          .doc(userId)
          .update(updateData);

      // Also update legacy structure for backward compatibility
      String legacyCollection = role == 'doctor' ? 'doctors' : 'pharmacies';
      await _firestore
          .collection(legacyCollection)
          .doc(userId)
          .update(updateData);

      // Update main user lookup if basic info changed
      Map<String, dynamic> userUpdates = {};
      if (updates.containsKey('name')) userUpdates['name'] = updates['name'];
      if (updates.containsKey('email')) userUpdates['email'] = updates['email'];
      if (updates.containsKey('phoneNumber'))
        userUpdates['phoneNumber'] = updates['phoneNumber'];

      if (userUpdates.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(userUpdates);
      }

      print(
        'User profile updated successfully in both new and legacy structures for $userId',
      );
      return true;
    } catch (e) {
      print('Update user profile error: $e');
      return false;
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
        await prefs.setString(
          'pharmacyName',
          profileData['pharmacyName'] ?? profileData['name'] ?? '',
        );
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

  // Helper method to get all doctors from Firebase
  static Future<List<Map<String, dynamic>>> getAllDoctors() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('doctors')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }

  // Helper method to get all pharmacies from Firebase
  static Future<List<Map<String, dynamic>>> getAllPharmacies() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('pharmacies')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error fetching pharmacies: $e');
      return [];
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

  // Test method to verify Firebase structure
  static Future<void> testFirebaseStructure() async {
    try {
      print('Testing Firebase structure...');

      // Test reading from top-level doctors
      QuerySnapshot doctorsSnapshot = await _firestore
          .collection('doctors')
          .limit(1)
          .get();
      print(
        'Doctors collection accessible: ${doctorsSnapshot.docs.isNotEmpty}',
      );

      // Test reading from top-level pharmacies
      QuerySnapshot pharmaciesSnapshot = await _firestore
          .collection('pharmacies')
          .limit(1)
          .get();
      print(
        'Pharmacies collection accessible: ${pharmaciesSnapshot.docs.isNotEmpty}',
      );

      print('Firebase structure test completed successfully');
    } catch (e) {
      print('Firebase structure test failed: $e');
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

  // TEMPORARY: Test method to create profile for existing user
  static Future<void> testCreateProfileForCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      print('🧪 TESTING: Creating profile for existing user: ${user.uid}');
      try {
        await createUserProfile(
          userId: user.uid,
          role: 'doctor', // Test as doctor
          userData: {
            'email': user.email ?? 'test@example.com',
            'name': 'Test Doctor',
            'phoneNumber': '1234567890',
            'licenseNumber': 'TEST123',
            'specialty': 'General Physician',
            'qualification': 'MBBS',
          },
        );
        print('🎉 TEST: Profile creation completed!');
      } catch (e) {
        print('❌ TEST: Profile creation failed: $e');
      }
    } else {
      print('❌ TEST: No current user found');
    }
  }

  // AUTOMATIC: Simple Firebase write test
  static Future<void> testFirebaseWriteCapability() async {
    print('🔥 FIREBASE WRITE TEST: Starting simple write test...');
    try {
      // Test 1: Simple document write
      await _firestore.collection('test').doc('write_test').set({
        'message': 'Hello Firestore',
        'timestamp': FieldValue.serverTimestamp(),
        'test_type': 'write_capability_test',
      });
      print('✅ FIREBASE WRITE TEST: Simple write successful!');

      // Test 2: Try to read it back
      DocumentSnapshot doc = await _firestore
          .collection('test')
          .doc('write_test')
          .get();
      if (doc.exists) {
        print('✅ FIREBASE READ TEST: Document exists and readable!');
        print('📄 Document data: ${doc.data()}');
      } else {
        print('❌ FIREBASE READ TEST: Document not found after write!');
      }

      // Clean up
      await _firestore.collection('test').doc('write_test').delete();
      print('🧹 FIREBASE CLEANUP: Test document deleted');
    } catch (e) {
      print('❌ FIREBASE WRITE TEST FAILED: $e');
      if (e.toString().contains('PERMISSION_DENIED')) {
        print('🚫 FIREBASE SECURITY RULES: Write operations are blocked!');
        print(
          '🔧 SOLUTION: Update your Firestore security rules to allow writes',
        );
      } else if (e.toString().contains('network')) {
        print('🌐 NETWORK ISSUE: Check internet connection');
      } else {
        print('🔍 UNKNOWN ERROR: ${e.runtimeType} - ${e.toString()}');
      }
    }
  }
}

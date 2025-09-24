import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum UserRole { doctor, pharmacy }

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  UserRole? _currentRole;
  String? _currentUserId;
  String? _currentUserName;
  String? _currentPharmacyName;
  Map<String, dynamic>? _currentUserProfile;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserRole? get currentRole => _currentRole;
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  String? get currentPharmacyName => _currentPharmacyName;
  Map<String, dynamic>? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUserId != null;
  bool get isDoctor => _currentRole == UserRole.doctor;
  bool get isPharmacy => _currentRole == UserRole.pharmacy;

  // Setters
  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void setUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  void setUserName(String name) {
    _currentUserName = name;
    notifyListeners();
  }

  void setPharmacyName(String name) {
    _currentPharmacyName = name;
    notifyListeners();
  }

  void setUserProfile(Map<String, dynamic> profile) {
    _currentUserProfile = profile;
    _currentRole = profile['role'] == 'doctor' ? UserRole.doctor : UserRole.pharmacy;
    _currentUserName = profile['name'];
    if (profile['role'] == 'pharmacy') {
      _currentPharmacyName = profile['pharmacyName'] ?? profile['name'];
    }
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Initialize user data
  Future<void> initializeUser() async {
    setLoading(true);
    setError(null);
    
    try {
      User? user = AuthService.currentUser;
      if (user != null) {
        print('Initializing user from Firebase: ${user.uid}');
        setUserId(user.uid);
        
        // Load user profile
        Map<String, dynamic>? profile = await AuthService.getUserProfile(user.uid);
        if (profile != null) {
          print('Profile loaded from Firestore: ${profile['name']} (${profile['role']})');
          setUserProfile(profile);
        } else {
          print('No profile found in Firestore, trying local data');
          // Try to load from local data as fallback
          Map<String, String?> localData = await AuthService.loadUserDataLocally();
          if (localData['userId'] != null) {
            setUserId(localData['userId']!);
            if (localData['userRole'] == 'doctor') {
              setRole(UserRole.doctor);
              if (localData['userName'] != null) {
                setUserName(localData['userName']!);
              }
            } else if (localData['userRole'] == 'pharmacy') {
              setRole(UserRole.pharmacy);
              if (localData['pharmacyName'] != null) {
                setPharmacyName(localData['pharmacyName']!);
              }
            }
            print('Initialized from local data: ${localData.toString()}');
          }
        }
      } else {
        print('No Firebase user found, trying local data');
        // No Firebase user, try local data
        Map<String, String?> localData = await AuthService.loadUserDataLocally();
        if (localData['userId'] != null) {
          setUserId(localData['userId']!);
          if (localData['userRole'] == 'doctor') {
            setRole(UserRole.doctor);
            if (localData['userName'] != null) {
              setUserName(localData['userName']!);
            }
          } else if (localData['userRole'] == 'pharmacy') {
            setRole(UserRole.pharmacy);
            if (localData['pharmacyName'] != null) {
              setPharmacyName(localData['pharmacyName']!);
            }
          }
          print('Initialized from local data (no Firebase): ${localData.toString()}');
        }
      }
    } catch (e) {
      print('Error initializing user: $e');
      setError('Failed to load user data: $e');
      
      // As final fallback, try local data
      try {
        Map<String, String?> localData = await AuthService.loadUserDataLocally();
        if (localData['userId'] != null) {
          setUserId(localData['userId']!);
          if (localData['userRole'] == 'doctor') {
            setRole(UserRole.doctor);
            if (localData['userName'] != null) {
              setUserName(localData['userName']!);
            }
          } else if (localData['userRole'] == 'pharmacy') {
            setRole(UserRole.pharmacy);
            if (localData['pharmacyName'] != null) {
              setPharmacyName(localData['pharmacyName']!);
            }
          }
          print('Fallback to local data successful');
          setError(null); // Clear error if local data works
        }
      } catch (localError) {
        print('Local data fallback also failed: $localError');
      }
    } finally {
      setLoading(false);
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (_currentUserId == null || _currentRole == null) return;
    
    setLoading(true);
    setError(null);
    
    try {
      await AuthService.updateUserProfile(
        userId: _currentUserId!,
        role: _currentRole == UserRole.doctor ? 'doctor' : 'pharmacy',
        updates: updates,
      );
      
      // Update local profile
      if (_currentUserProfile != null) {
        _currentUserProfile!.addAll(updates);
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to update profile: $e');
    } finally {
      setLoading(false);
    }
  }

  // Sign out and reset state
  Future<void> signOut() async {
    setLoading(true);
    setError(null);
    
    try {
      await AuthService.signOut();
      reset();
    } catch (e) {
      setError('Failed to sign out: $e');
    } finally {
      setLoading(false);
    }
  }

  void reset() {
    _currentRole = null;
    _currentUserId = null;
    _currentUserName = null;
    _currentPharmacyName = null;
    _currentUserProfile = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Static methods for backward compatibility
  static UserRole? get staticCurrentRole => _instance._currentRole;
  static String? get staticCurrentUserName => _instance._currentUserName;
  static String? get staticCurrentPharmacyName => _instance._currentPharmacyName;

  static void staticSetRole(UserRole role) => _instance.setRole(role);
  static void staticSetUserName(String name) => _instance.setUserName(name);
  static void staticSetPharmacyName(String name) => _instance.setPharmacyName(name);
  static void staticReset() => _instance.reset();
}

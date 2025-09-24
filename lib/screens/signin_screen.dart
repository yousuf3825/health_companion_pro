import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_state.dart';
import '../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if user just came from successful registration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['showSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please sign in with your credentials.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      UserCredential? userCredential;
      bool tempLoginSuccess = false;
      bool loginSuccessful = false;

      try {
        userCredential = await AuthService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        // Check if user is authenticated (even if UserCredential is null due to type errors)
        User? currentUser = AuthService.currentUser;
        if (userCredential != null && userCredential.user != null) {
          loginSuccessful = true;
        } else if (currentUser != null && currentUser.email == email) {
          // User is authenticated despite UserCredential issues
          loginSuccessful = true;
          print('User authenticated despite UserCredential type error');
        }
      } on FirebaseAuthException catch (e) {
        print('Firebase Auth Exception in SignIn: ${e.code} - ${e.message}');
        
        if (e.code == 'user-not-found' || 
            e.code == 'unknown' || 
            e.code == 'type-error' ||
            e.message?.contains('CONFIGURATION_NOT_FOUND') == true ||
            e.message?.toLowerCase().contains('pigeonuserdetails') == true) {
          // Try temporary login as fallback
          print('Attempting temporary login fallback');
          tempLoginSuccess = await AuthService.loginUserTemporary(
            email: email,
            password: password,
          );
          
          if (tempLoginSuccess) {
            loginSuccessful = true;
          } else {
            throw e;
          }
        } else {
          throw e;
        }
      } catch (e) {
        print('General login error: $e');
        // Try temporary login as final fallback for any type errors
        if (e.toString().contains('PigeonUserDetails') || 
            e.toString().contains('ListOfObject') ||
            e.toString().contains('type') ||
            e.toString().contains('cast')) {
          print('Type error detected, attempting temporary login');
          try {
            tempLoginSuccess = await AuthService.loginUserTemporary(
              email: email,
              password: password,
            );
            
            if (tempLoginSuccess) {
              loginSuccessful = true;
              print('Fallback to temporary login successful');
            } else {
              throw e;
            }
          } catch (tempError) {
            throw e; // Throw original error
          }
        } else {
          throw e;
        }
      }

      // Handle successful login
      if (loginSuccessful) {
        final appState = Provider.of<AppState>(context, listen: false);
        
        if (userCredential != null && userCredential.user != null) {
          // Firebase login - initialize from Firebase + Firestore
          print('Initializing Firebase user: ${userCredential.user!.uid}');
          
          // Set basic user info first
          appState.setUserId(userCredential.user!.uid);
          
          // Try to load profile from Firestore
          try {
            await appState.initializeUser();
          } catch (e) {
            print('Error loading from Firestore: $e');
            // Fallback: set default values based on email
            String email = userCredential.user!.email ?? '';
            if (email.contains('@')) {
              String name = email.split('@')[0];
              // Default to pharmacy for now (can be changed later)
              appState.setRole(UserRole.pharmacy);
              appState.setPharmacyName(name.toUpperCase());
              
              // Save local data for persistence
              Map<String, dynamic> fallbackData = {
                'name': name,
                'email': email,
                'role': 'pharmacy',
                'pharmacyName': name.toUpperCase(),
              };
              await AuthService.saveUserDataLocally(userCredential.user!.uid, 'pharmacy', fallbackData);
            }
          }
        } else if (AuthService.currentUser != null && AuthService.currentUser!.email == email) {
          // User authenticated but UserCredential has type issues
          User currentUser = AuthService.currentUser!;
          print('Handling authenticated user with type error: ${currentUser.uid}');
          
          appState.setUserId(currentUser.uid);
          
          try {
            await appState.initializeUser();
          } catch (e) {
            print('Error loading from Firestore for current user: $e');
            // Fallback: set default values based on email
            String userEmail = currentUser.email ?? email;
            if (userEmail.contains('@')) {
              String name = userEmail.split('@')[0];
              appState.setRole(UserRole.pharmacy);
              appState.setPharmacyName(name.toUpperCase());
              
              Map<String, dynamic> fallbackData = {
                'name': name,
                'email': userEmail,
                'role': 'pharmacy',
                'pharmacyName': name.toUpperCase(),
              };
              await AuthService.saveUserDataLocally(currentUser.uid, 'pharmacy', fallbackData);
            }
          }
        } else if (tempLoginSuccess) {
          // Temporary login - initialize from local storage
          print('Initializing temporary user from local storage');
          Map<String, String?> localData = await AuthService.loadUserDataLocally();
          
          if (localData['userId'] != null) {
            appState.setUserId(localData['userId']!);
            
            // Set role first
            if (localData['userRole'] == 'doctor') {
              appState.setRole(UserRole.doctor);
              if (localData['userName'] != null && localData['userName']!.isNotEmpty) {
                appState.setUserName(localData['userName']!);
              } else {
                appState.setUserName('Doctor User');
              }
            } else if (localData['userRole'] == 'pharmacy') {
              appState.setRole(UserRole.pharmacy);
              if (localData['pharmacyName'] != null && localData['pharmacyName']!.isNotEmpty) {
                appState.setPharmacyName(localData['pharmacyName']!);
              } else {
                appState.setPharmacyName('Pharmacy');
              }
            } else {
              // Default fallback
              appState.setRole(UserRole.pharmacy);
              appState.setPharmacyName('Pharmacy');
            }
            
            print('Local user data loaded: ${localData.toString()}');
          } else {
            // No local data - set defaults
            print('No local data found, setting defaults');
            appState.setUserId(DateTime.now().millisecondsSinceEpoch.toString());
            appState.setRole(UserRole.pharmacy);
            appState.setPharmacyName('Pharmacy');
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(tempLoginSuccess 
                ? 'Welcome back! (Temporary mode)' 
                : 'Welcome back!'),
              backgroundColor: tempLoginSuccess ? Colors.orange : Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Sign in failed';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'user-disabled':
          errorMessage = 'Your account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
        default:
          errorMessage = 'Sign in failed: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.medical_services,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue to MedConnect Pro',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Sign In Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Forgot password feature coming soon'),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Sign In Button
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading 
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
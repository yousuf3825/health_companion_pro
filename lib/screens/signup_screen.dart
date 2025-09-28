import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/auth_service.dart';
import 'doctor_details_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.doctor;
  bool _agreeToTerms = false;

  // Additional fields for role-specific information
  String? _selectedSpecialty;
  String? _selectedQualification;
  final _pharmacyNameController = TextEditingController();

  final List<String> _specialties = [
    'General Physician',
    'Pediatrician',
    'Cardiologist',
    'Dermatologist',
    'Orthopedic',
    'Neurologist',
    'Psychiatrist',
    'Gynecologist',
    'ENT Specialist',
    'Ophthalmologist',
  ];

  final List<String> _qualifications = [
    'MBBS',
    'MD',
    'MS',
    'DM',
    'MCh',
    'DNB',
    'BAMS',
    'BHMS',
    'BDS',
    'MDS',
  ];

  @override
  void initState() {
    super.initState();
    // Get the selected role from AppState (set by role selection screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.currentRole != null) {
        setState(() {
          _selectedRole = appState.currentRole!;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _pharmacyNameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms and Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isDoctor = _selectedRole == UserRole.doctor;

      // Prepare profile data
      Map<String, dynamic> profileData = {
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'licenseNumber': _licenseController.text.trim(),
        'role': isDoctor ? 'doctor' : 'pharmacy', // Document field (singular)
      };

      if (isDoctor) {
        profileData.addAll({
          'specialty': _selectedSpecialty ?? 'General Physician',
          'qualification': _selectedQualification ?? 'MBBS',
          'experience': '1 year',
          'hospital': 'Not specified',
        });
      } else {
        profileData.addAll({
          'pharmacyName': _pharmacyNameController.text.trim(),
          'ownerName': _nameController.text.trim(),
          'gstNumber': 'Not specified',
          'address': 'Not specified',
        });
      }

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      UserCredential? userCredential;
      bool tempRegistrationSuccess = false;
      bool registrationSuccessful = false;

      try {
        userCredential = await AuthService.signUpWithEmailAndPassword(
          email: email,
          password: password,
          role: isDoctor ? 'doctors' : 'pharmacies', // Collection name (plural)
          profileData: profileData,
        );

        if (userCredential != null && userCredential.user != null) {
          registrationSuccessful = true;
        }
      } on FirebaseAuthException catch (e) {
        print('Firebase Auth Exception: ${e.code} - ${e.message}');

        if (e.code == 'configuration-error' ||
            e.code == 'type-error' ||
            (e.code == 'unknown' &&
                e.message?.contains('CONFIGURATION_NOT_FOUND') == true) ||
            e.code.contains('network-request-failed') ||
            e.message?.toLowerCase().contains('pigeonuserdetails') == true) {
          // Use temporary registration as fallback for various Firebase issues
          print(
            'Using temporary registration due to Firebase issue: ${e.code}',
          );
          tempRegistrationSuccess = await AuthService.registerUserTemporary(
            email: email,
            password: password,
            role: isDoctor ? 'doctors' : 'pharmacies', // Changed to plural
            profileData: profileData,
          );

          if (tempRegistrationSuccess) {
            registrationSuccessful = true;

            // IMPORTANT: Even with temporary registration, try to create Firebase profile
            // if user was actually created in Firebase Auth
            try {
              User? currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                print('🔥 User exists in Firebase Auth: ${currentUser.uid}');
                print(
                  '🔥 Attempting to create Firebase profile despite type error...',
                );

                await AuthService.createUserProfile(
                  userId: currentUser.uid,
                  role: isDoctor
                      ? 'doctors'
                      : 'pharmacies', // Changed to plural
                  userData: {'email': email, ...profileData},
                );

                print(
                  '✅ Firebase profile created successfully despite initial type error!',
                );
              }
            } catch (profileError) {
              print('❌ Failed to create Firebase profile: $profileError');
              // Don't fail the registration - at least we have local storage
            }
          } else {
            throw e;
          }
        } else {
          throw e;
        }
      } catch (e) {
        print('General registration error: $e');
        // Try temporary registration as final fallback
        try {
          tempRegistrationSuccess = await AuthService.registerUserTemporary(
            email: email,
            password: password,
            role: isDoctor ? 'doctors' : 'pharmacies', // Changed to plural
            profileData: profileData,
          );

          if (tempRegistrationSuccess) {
            registrationSuccessful = true;
            print('Fallback to temporary registration successful');

            // IMPORTANT: Even with temporary registration, try to create Firebase profile
            // if user was actually created in Firebase Auth
            try {
              User? currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                print('🔥 User exists in Firebase Auth: ${currentUser.uid}');
                print(
                  '🔥 Attempting to create Firebase profile despite type error...',
                );

                await AuthService.createUserProfile(
                  userId: currentUser.uid,
                  role: isDoctor
                      ? 'doctors'
                      : 'pharmacies', // Changed to plural
                  userData: {'email': email, ...profileData},
                );

                print(
                  '✅ Firebase profile created successfully despite initial type error!',
                );
              }
            } catch (profileError) {
              print('❌ Failed to create Firebase profile: $profileError');
              // Don't fail the registration - at least we have local storage
            }
          } else {
            throw e;
          }
        } catch (tempError) {
          throw e; // Throw original error
        }
      }

      // Handle successful registration
      if (registrationSuccessful) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tempRegistrationSuccess
                    ? 'Account created successfully! Please complete your profile.'
                    : 'Account created successfully! Please complete your profile.',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // For doctors, navigate to profile completion
          if (isDoctor) {
            // Get current user for doctor details screen
            User? currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorDetailsScreen(
                    userId: currentUser.uid,
                    basicProfileData: {
                      'name': _nameController.text.trim(),
                      'email': _emailController.text.trim(),
                      'phoneNumber': _phoneController.text.trim(),
                      'licenseNumber': _licenseController.text.trim(),
                      'role': 'doctor',
                    },
                  ),
                ),
              );
            } else {
              // Fallback to signin if no current user
              Navigator.pushReplacementNamed(
                context,
                '/signin',
                arguments: {'showSuccess': true},
              );
            }
          } else {
            // For pharmacies, go directly to signin (they already have complete profile)
            Navigator.pushReplacementNamed(
              context,
              '/signin',
              arguments: {'showSuccess': true},
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Use at least 6 characters';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'configuration-error':
          errorMessage =
              'Firebase not properly configured. Please add SHA-1: 0E:AF:CF:61:64:AE:74:1D:B2:A6:54:E9:FD:5C:0E:B2:08:A2:63:1B';
          break;
        case 'unknown':
          if (e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
            errorMessage =
                'Firebase configuration error. Add SHA-1 fingerprint to Firebase Console: 0E:AF:CF:61:64:AE:74:1D:B2:A6:54:E9:FD:5C:0E:B2:08:A2:63:1B';
          } else {
            errorMessage = 'Registration failed: ${e.message}';
          }
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration error: $e'),
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
                const SizedBox(height: 20),

                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_add,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join MedConnect Pro today',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Role Selection
                Text(
                  'I am a:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleCard(
                        role: UserRole.doctor,
                        title: 'Doctor',
                        subtitle: 'Medical Professional',
                        icon: Icons.local_hospital,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildRoleCard(
                        role: UserRole.pharmacy,
                        title: 'Pharmacy',
                        subtitle: 'Medicine Provider',
                        icon: Icons.local_pharmacy,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Sign Up Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name Field
                      _buildTextField(
                        controller: _nameController,
                        label: _selectedRole == UserRole.doctor
                            ? 'Full Name'
                            : 'Pharmacy/Owner Name',
                        hint:
                            'Enter your ${_selectedRole == UserRole.doctor ? 'full name' : 'pharmacy or owner name'}',
                        icon: Icons.person_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Pharmacy Name Field (only for pharmacy)
                      if (_selectedRole == UserRole.pharmacy) ...[
                        _buildTextField(
                          controller: _pharmacyNameController,
                          label: 'Pharmacy Name',
                          hint: 'Enter your pharmacy name',
                          icon: Icons.local_pharmacy,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter pharmacy name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Email Field
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'Enter your email address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Phone Field
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: 'Enter your phone number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // License Field
                      _buildTextField(
                        controller: _licenseController,
                        label: _selectedRole == UserRole.doctor
                            ? 'Medical License'
                            : 'Pharmacy License',
                        hint: 'Enter your license number',
                        icon: Icons.badge_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your license number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Role-specific fields
                      if (_selectedRole == UserRole.doctor) ...[
                        _buildDropdownField(
                          label: 'Specialty',
                          value: _selectedSpecialty,
                          items: _specialties,
                          icon: Icons.local_hospital,
                          onChanged: (value) {
                            setState(() {
                              _selectedSpecialty = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDropdownField(
                          label: 'Qualification',
                          value: _selectedQualification,
                          items: _qualifications,
                          icon: Icons.school_outlined,
                          onChanged: (value) {
                            setState(() {
                              _selectedQualification = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Password Field
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Create a strong password',
                        icon: Icons.lock_outlined,
                        obscureText: _obscurePassword,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Confirm Password Field
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        icon: Icons.lock_outlined,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Terms and Conditions
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _agreeToTerms = !_agreeToTerms;
                                });
                              },
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' and ',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Sign Up Button
                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
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
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/signin',
                                (route) => false,
                              );
                            },
                            child: Text(
                              'Sign In',
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

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
              : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black87,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}

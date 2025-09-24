import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_state.dart';
import '../services/auth_service.dart';

class RegistrationVerificationScreen extends StatefulWidget {
  const RegistrationVerificationScreen({super.key});

  @override
  State<RegistrationVerificationScreen> createState() =>
      _RegistrationVerificationScreenState();
}

class _RegistrationVerificationScreenState
    extends State<RegistrationVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _licenseController = TextEditingController();
  bool _isLoading = false;

  String? _selectedSpecialty;
  String? _selectedQualification;

  final List<String> _specialties = [
    'General Practitioner',
    'Pediatrician',
    'Cardiologist',
    'Dermatologist',
    'Orthopedic',
    'Neurologist',
    'Psychiatrist',
  ];

  final List<String> _qualifications = ['MBBS', 'MD', 'MS', 'DM', 'MCh', 'DNB'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final isDoctor = appState.currentRole == UserRole.doctor;
      
      // Prepare profile data
      Map<String, dynamic> profileData = {
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'licenseNumber': _licenseController.text.trim(),
        'role': isDoctor ? 'doctor' : 'pharmacy',
      };

      if (isDoctor) {
        profileData.addAll({
          'specialty': _selectedSpecialty ?? 'General Practitioner',
          'qualification': _selectedQualification ?? 'MBBS',
          'experience': '5 years',
          'hospital': 'City General Hospital',
        });
      } else {
        profileData.addAll({
          'pharmacyName': _nameController.text.trim(),
          'ownerName': 'Dr. John Smith',
          'gstNumber': 'GST123456789',
          'address': '123 Medical Street, City',
        });
      }

      // Register with Firebase - use email directly instead of phone conversion
      String password = _passwordController.text.trim().isEmpty 
          ? 'medconnect123' // Default password for demo
          : _passwordController.text.trim();

      // Require email input
      if (_emailController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email address'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String email = _emailController.text.trim();

      UserCredential? userCredential;
      try {
        userCredential = await AuthService.signUpWithEmailAndPassword(
          email: email,
          password: password,
          role: isDoctor ? 'doctor' : 'pharmacy',
          profileData: profileData,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'configuration-error' || 
            (e.code == 'unknown' && e.message?.contains('CONFIGURATION_NOT_FOUND') == true)) {
          // Use temporary registration as fallback
          print('Using temporary registration due to Firebase configuration issue');
          bool success = await AuthService.registerUserTemporary(
            email: email,
            password: password,
            role: isDoctor ? 'doctor' : 'pharmacy',
            profileData: profileData,
          );
          
          if (success) {
            // Set user data in app state
            final appState = Provider.of<AppState>(context, listen: false);
            appState.setUserId(DateTime.now().millisecondsSinceEpoch.toString());
            if (isDoctor) {
              appState.setUserName(_nameController.text.trim());
            } else {
              appState.setPharmacyName(_nameController.text.trim());
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registration successful! (Temporary mode - Please configure Firebase SHA-1)'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 4),
                ),
              );

              Navigator.pushReplacementNamed(context, '/login');
            }
            return;
          }
        }
        throw e; // Re-throw other Firebase errors
      }

      if (userCredential != null && userCredential.user != null) {
        // Set user data in app state
        appState.setUserId(userCredential.user!.uid);
        if (isDoctor) {
          appState.setUserName(_nameController.text.trim());
        } else {
          appState.setPharmacyName(_nameController.text.trim());
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! You can now login.'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'configuration-error':
          errorMessage = 'Firebase not properly configured. Please add SHA-1: 0E:AF:CF:61:64:AE:74:1D:B2:A6:54:E9:FD:5C:0E:B2:08:A2:63:1B';
          break;
        case 'unknown':
          if (e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
            errorMessage = 'Firebase configuration error. Add SHA-1 fingerprint to Firebase Console: 0E:AF:CF:61:64:AE:74:1D:B2:A6:54:E9:FD:5C:0E:B2:08:A2:63:1B';
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isDoctor = appState.currentRole == UserRole.doctor;

    return Scaffold(
      appBar: AppBar(
        title: Text('${isDoctor ? 'Doctor' : 'Pharmacy'} Registration'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complete your profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please fill in all required information for verification',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Basic Information Section
              _SectionTitle(title: 'Basic Information'),
              const SizedBox(height: 16),

              _CustomTextField(
                controller: _nameController,
                label: isDoctor ? 'Full Name' : 'Pharmacy/Store Name',
                prefixIcon: isDoctor ? Icons.person : Icons.store,
              ),
              const SizedBox(height: 16),

              if (isDoctor) ...[
                // Doctor-specific fields
                _CustomDropdown(
                  label: 'Specialty',
                  value: _selectedSpecialty,
                  items: _specialties,
                  onChanged:
                      (value) => setState(() => _selectedSpecialty = value),
                  prefixIcon: Icons.medical_services,
                ),
                const SizedBox(height: 16),

                _CustomDropdown(
                  label: 'Qualification',
                  value: _selectedQualification,
                  items: _qualifications,
                  onChanged:
                      (value) => setState(() => _selectedQualification = value),
                  prefixIcon: Icons.school,
                ),
                const SizedBox(height: 16),

                _CustomTextField(
                  controller: _licenseController,
                  label: 'Medical License Number',
                  prefixIcon: Icons.card_membership,
                ),
                const SizedBox(height: 16),

                _CustomTextField(
                  controller: TextEditingController(text: '5 years'),
                  label: 'Years of Experience',
                  prefixIcon: Icons.work_history,
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                _CustomTextField(
                  controller: TextEditingController(
                    text: 'City General Hospital',
                  ),
                  label: 'Hospital/Clinic Affiliation',
                  prefixIcon: Icons.local_hospital,
                  readOnly: true,
                ),
              ] else ...[
                // Pharmacy-specific fields
                _CustomTextField(
                  controller: TextEditingController(text: 'Dr. John Smith'),
                  label: 'Owner/Pharmacist Name',
                  prefixIcon: Icons.person,
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                _CustomTextField(
                  controller: _licenseController,
                  label: 'Drug License Number',
                  prefixIcon: Icons.card_membership,
                ),
                const SizedBox(height: 16),

                _CustomTextField(
                  controller: TextEditingController(text: 'GST123456789'),
                  label: 'GST Number',
                  prefixIcon: Icons.receipt,
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                _CustomTextField(
                  controller: TextEditingController(
                    text: '123 Medical Street, City',
                  ),
                  label: 'Location/Address',
                  prefixIcon: Icons.location_on,
                  readOnly: true,
                  maxLines: 2,
                ),
              ],

              const SizedBox(height: 16),

              // Contact Information Section
              _SectionTitle(title: 'Contact Information'),
              const SizedBox(height: 16),

              _CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _CustomTextField(
                controller: _emailController,
                label: 'Email (required)',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              _CustomTextField(
                controller: _passwordController,
                label: 'Password',
                prefixIcon: Icons.lock,
                obscureText: true,
              ),

              if (isDoctor) ...[
                const SizedBox(height: 16),
                _SectionTitle(title: 'Available Time Slots'),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Time Slots:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Wrap(
                        spacing: 8,
                        children: [
                          Chip(label: Text('9:00 AM - 11:00 AM')),
                          Chip(label: Text('2:00 PM - 4:00 PM')),
                          Chip(label: Text('6:00 PM - 8:00 PM')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Upload Documents Section
              _SectionTitle(title: 'Upload Documents'),
              const SizedBox(height: 16),

              _UploadItem(
                title: isDoctor ? 'Profile Photo' : 'Store Photo',
                subtitle: 'Upload your ${isDoctor ? 'profile' : 'store'} photo',
                icon: Icons.photo,
              ),
              const SizedBox(height: 12),

              _UploadItem(
                title: 'Government ID Proof',
                subtitle: 'Aadhar Card, Passport, etc.',
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 12),

              _UploadItem(
                title: isDoctor ? 'Medical License' : 'Drug License',
                subtitle: 'Upload your license certificate',
                icon: Icons.file_copy,
              ),

              if (isDoctor) ...[
                const SizedBox(height: 12),
                _UploadItem(
                  title: 'Degree Certificate',
                  subtitle: 'Upload your qualification certificate',
                  icon: Icons.school,
                ),
              ],

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Register & Create Account',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
      }
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool readOnly;
  final int maxLines;
  final bool obscureText;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.keyboardType,
    this.readOnly = false,
    this.maxLines = 1,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[100] : null,
      ),
      validator: (value) {
        if (!readOnly && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}

class _CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData prefixIcon;

  const _CustomDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }
}

class _UploadItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _UploadItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload $title functionality')),
              );
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}

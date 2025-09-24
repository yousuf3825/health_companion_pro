import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _pharmacyNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _gstController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final appState = Provider.of<AppState>(context, listen: false);
    final profile = appState.currentUserProfile;
    
    if (profile != null) {
      _nameController.text = profile['name'] ?? '';
      _emailController.text = profile['email'] ?? '';
      _phoneController.text = profile['phoneNumber'] ?? profile['phone'] ?? '';
      _licenseController.text = profile['licenseNumber'] ?? '';
      
      if (appState.isDoctor) {
        _specialtyController.text = profile['specialty'] ?? '';
        _qualificationController.text = profile['qualification'] ?? '';
        _experienceController.text = profile['experience'] ?? '';
        _hospitalController.text = profile['hospital'] ?? '';
      } else {
        _pharmacyNameController.text = profile['pharmacyName'] ?? '';
        _ownerNameController.text = profile['ownerName'] ?? '';
        _gstController.text = profile['gstNumber'] ?? '';
        _addressController.text = profile['address'] ?? '';
      }
    } else {
      // Load from app state if profile is not available
      _nameController.text = appState.currentUserName ?? '';
      if (appState.isPharmacy) {
        _pharmacyNameController.text = appState.currentPharmacyName ?? '';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _specialtyController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _hospitalController.dispose();
    _pharmacyNameController.dispose();
    _ownerNameController.dispose();
    _gstController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final isDoctor = appState.isDoctor;
      
      Map<String, dynamic> updates = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'licenseNumber': _licenseController.text.trim(),
      };

      if (isDoctor) {
        updates.addAll({
          'specialty': _specialtyController.text.trim(),
          'qualification': _qualificationController.text.trim(),
          'experience': _experienceController.text.trim(),
          'hospital': _hospitalController.text.trim(),
        });
      } else {
        updates.addAll({
          'pharmacyName': _pharmacyNameController.text.trim(),
          'ownerName': _ownerNameController.text.trim(),
          'gstNumber': _gstController.text.trim(),
          'address': _addressController.text.trim(),
        });
      }

      // Update profile
      await appState.updateUserProfile(updates);

      // Update app state
      appState.setUserName(_nameController.text.trim());
      if (!isDoctor) {
        appState.setPharmacyName(_pharmacyNameController.text.trim());
      }

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
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
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final isDoctor = appState.isDoctor;
          final userName = isDoctor 
              ? appState.currentUserName ?? 'Doctor'
              : appState.currentPharmacyName ?? 'Pharmacy';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              isDoctor ? 'DR' : userName.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isDoctor ? 'Dr. $userName' : userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isDoctor ? 'Medical Professional' : 'Pharmacy',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildProfileStat('Years of\nExperience', '5+'),
                          _buildProfileStat(isDoctor ? 'Patients\nTreated' : 'Orders\nCompleted', '200+'),
                          _buildProfileStat('Rating', '4.8★'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Profile Form
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Personal Information',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person,
                          enabled: _isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          enabled: false, // Email shouldn't be editable
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone,
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _licenseController,
                          label: 'License Number',
                          icon: Icons.badge,
                          enabled: _isEditing,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your license number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Role-specific fields
                        if (isDoctor) ...[
                          Text(
                            'Professional Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _specialtyController,
                            label: 'Specialty',
                            icon: Icons.local_hospital,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _qualificationController,
                            label: 'Qualification',
                            icon: Icons.school,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _experienceController,
                            label: 'Experience',
                            icon: Icons.work,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _hospitalController,
                            label: 'Hospital/Clinic',
                            icon: Icons.business,
                            enabled: _isEditing,
                          ),
                        ] else ...[
                          Text(
                            'Pharmacy Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _pharmacyNameController,
                            label: 'Pharmacy Name',
                            icon: Icons.local_pharmacy,
                            enabled: _isEditing,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter pharmacy name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _ownerNameController,
                            label: 'Owner Name',
                            icon: Icons.person_outline,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _gstController,
                            label: 'GST Number',
                            icon: Icons.receipt_long,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: _addressController,
                            label: 'Address',
                            icon: Icons.location_on,
                            enabled: _isEditing,
                            maxLines: 3,
                          ),
                        ],

                        const SizedBox(height: 32),

                        if (_isEditing) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: _isLoading 
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text('Save Changes'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isLoading ? null : () {
                                    setState(() {
                                      _isEditing = false;
                                    });
                                    _loadUserData(); // Reload original data
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
    );
  }
}
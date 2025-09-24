import 'package:flutter/material.dart';
import '../models/app_state.dart';

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
  final _licenseController = TextEditingController();

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
  Widget build(BuildContext context) {
    final isDoctor = AppState.currentRole == UserRole.doctor;

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
                label: 'Email',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Set user name based on role
                      if (isDoctor) {
                        AppState.setUserName(_nameController.text);
                      } else {
                        AppState.setPharmacyName(_nameController.text);
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Registration submitted for verification',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pushNamed(context, '/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Submit for Verification',
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

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.keyboardType,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[100] : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
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
      value: value,
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

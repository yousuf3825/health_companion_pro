import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/auth_service.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> basicProfileData;

  const DoctorDetailsScreen({
    super.key,
    required this.userId,
    required this.basicProfileData,
  });

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _experienceController = TextEditingController();
  final _consultationFeeController = TextEditingController();
  final _additionalNotesController = TextEditingController();

  bool _isLoading = false;
  String _selectedSpecialty = 'General Practitioner';
  String _selectedQualification = 'MBBS';

  // Working hours
  final Map<String, Map<String, dynamic>> _workingHours = {
    'monday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '17:00'},
    'tuesday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '17:00'},
    'wednesday': {
      'isAvailable': true,
      'startTime': '09:00',
      'endTime': '17:00',
    },
    'thursday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '17:00'},
    'friday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '17:00'},
    'saturday': {'isAvailable': true, 'startTime': '09:00', 'endTime': '14:00'},
    'sunday': {'isAvailable': false, 'startTime': '09:00', 'endTime': '17:00'},
  };

  final List<String> _specialties = [
    'General Practitioner',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Neurologist',
    'Orthopedic Surgeon',
    'Psychiatrist',
    'Gynecologist',
    'ENT Specialist',
    'Ophthalmologist',
    'Endocrinologist',
    'Gastroenterologist',
    'Pulmonologist',
    'Urologist',
    'Radiologist',
  ];

  final List<String> _qualifications = [
    'MBBS',
    'MD',
    'MS',
    'MBBS, MD',
    'MBBS, MS',
    'BDS',
    'MDS',
    'BAMS',
    'BHMS',
    'BUMS',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _consultationFeeController.text = '500'; // Default consultation fee
    _experienceController.text = '1 year'; // Default experience
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _experienceController.dispose();
    _consultationFeeController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Combine basic profile data with doctor-specific details
      final completeProfileData = {
        ...widget.basicProfileData,
        'specialty': _selectedSpecialty,
        'qualification': _selectedQualification,
        'hospital': _hospitalController.text.trim().isEmpty
            ? 'Not specified'
            : _hospitalController.text.trim(),
        'experience': _experienceController.text.trim(),
        'consultationFee':
            int.tryParse(_consultationFeeController.text.trim()) ?? 500,
        'additionalNotes': _additionalNotesController.text.trim(),
        'workingHours': _workingHours,
        'profileComplete': true,
        'isActive': true,
        'isVerified': false,
        'rating': 4.5,
        'totalConsultations': 0,
      };

      // Save directly to /doctors collection
      await AuthService.updateUserProfileData(
        userId: widget.userId,
        role: 'doctors', // This will save to /doctors collection
        additionalData: completeProfileData,
      );

      if (mounted) {
        // Initialize app state with the new profile
        final appState = Provider.of<AppState>(context, listen: false);
        await appState.initializeUser();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor profile saved to /doctors collection successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      print('❌ Error saving to /doctors collection: $e'); // Add debugging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving to /doctors collection: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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

  Widget _buildWorkingHoursSection() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Working Hours',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._workingHours.entries.map((entry) {
              final day = entry.key;
              final dayData = entry.value;
              final dayName = day[0].toUpperCase() + day.substring(1);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        dayName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Switch(
                      value: dayData['isAvailable'],
                      onChanged: (value) {
                        setState(() {
                          _workingHours[day]!['isAvailable'] = value;
                        });
                      },
                    ),
                    if (dayData['isAvailable']) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: dayData['startTime'],
                                decoration: const InputDecoration(
                                  labelText: 'Start',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (value) {
                                  _workingHours[day]!['startTime'] = value;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('to'),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: dayData['endTime'],
                                decoration: const InputDecoration(
                                  labelText: 'End',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (value) {
                                  _workingHours[day]!['endTime'] = value;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Not available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.medical_services,
                        size: 48,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Doctor Profile Setup',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Please complete your professional details to start providing consultations.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Professional Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Professional Details',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Specialty Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedSpecialty,
                        decoration: const InputDecoration(
                          labelText: 'Medical Specialty *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_hospital),
                        ),
                        items: _specialties.map((String specialty) {
                          return DropdownMenuItem<String>(
                            value: specialty,
                            child: Text(specialty),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedSpecialty = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your specialty';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Qualification Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedQualification,
                        decoration: const InputDecoration(
                          labelText: 'Qualification *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),
                        ),
                        items: _qualifications.map((String qualification) {
                          return DropdownMenuItem<String>(
                            value: qualification,
                            child: Text(qualification),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedQualification = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your qualification';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Hospital (Optional)
                      TextFormField(
                        controller: _hospitalController,
                        decoration: const InputDecoration(
                          labelText: 'Hospital/Clinic (Optional)',
                          hintText: 'Enter your workplace',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        maxLines: 1,
                      ),

                      const SizedBox(height: 16),

                      // Experience
                      TextFormField(
                        controller: _experienceController,
                        decoration: const InputDecoration(
                          labelText: 'Experience *',
                          hintText: 'e.g., 5 years',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your experience';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Consultation Fee
                      TextFormField(
                        controller: _consultationFeeController,
                        decoration: const InputDecoration(
                          labelText: 'Consultation Fee (₹) *',
                          hintText: '500',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter consultation fee';
                          }
                          if (int.tryParse(value.trim()) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Additional Notes
                      TextFormField(
                        controller: _additionalNotesController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes (Optional)',
                          hintText:
                              'Any additional information about your practice',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Working Hours
              _buildWorkingHoursSection(),

              const SizedBox(height: 24),

              // Complete Profile Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Complete Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip Button (Optional)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // Create basic profile and skip detailed setup
                          _saveProfile();
                        },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  child: Text(
                    'Complete Later',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController(text: 'Rajesh Kumar');
  final _ageController = TextEditingController(text: '45');
  final _symptomsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _adviceController = TextEditingController();
  bool _isSaving = false;

  final List<Medicine> _medicines = [];
  final List<String> _commonMedicines = [
    'Paracetamol 500mg',
    'Amoxicillin 250mg',
    'Ibuprofen 400mg',
    'Omeprazole 20mg',
    'Cough Syrup',
    'Vitamin D3',
    'Calcium Tablets',
    'Iron Tablets',
  ];

  @override
  void initState() {
    super.initState();
    // Add some default medicines
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Prescription'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _savePrescriptionToFirebase,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient Information',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _patientNameController,
                              decoration: const InputDecoration(
                                labelText: 'Patient Name',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              controller: _ageController,
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                prefixIcon: Icon(Icons.cake),
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Consultation: ${DateTime.now().toString().split(' ')[0]} at 10:00 AM',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Symptoms & Diagnosis
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clinical Details',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _symptomsController,
                        decoration: const InputDecoration(
                          labelText: 'Symptoms',
                          hintText: 'Patient complaints and symptoms...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _diagnosisController,
                        decoration: const InputDecoration(
                          labelText: 'Diagnosis',
                          hintText: 'Clinical diagnosis...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Medicines Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Medicines',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _showAddMedicineDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Medicine'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_medicines.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.medical_services_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No medicines added yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap "Add Medicine" to start adding medicines',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _medicines.length,
                          itemBuilder: (context, index) {
                            final medicine = _medicines[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            medicine.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${medicine.dosage} • ${medicine.duration}',
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            medicine.instructions,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _removeMedicine(index),
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Advice Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doctor\'s Advice',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _adviceController,
                        decoration: const InputDecoration(
                          hintText: 'Additional advice and instructions...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Send Prescription Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _savePrescriptionToFirebase,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save & Send Prescription',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Save the prescription under /doctors/{uid}/prescriptions/{autoId}
  Future<void> _savePrescriptionToFirebase() async {
    // Minimal validation: require at least one medicine and some clinical text
    if (_medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one medicine'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final doctorId = user.uid;
      final prescriptionsCol = FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .collection('prescriptions');

      final newDoc = prescriptionsCol.doc();
      final prescriptionId = newDoc.id;

      // Build medicines array
      final meds = _medicines
          .map(
            (m) => {
              'name': m.name,
              'dosage': m.dosage,
              'duration': m.duration,
              'instructions': m.instructions,
            },
          )
          .toList();

      // Build the document
      final data = <String, dynamic>{
        'prescriptionId': prescriptionId,
        'doctorId': doctorId,

        // Patient details (from this page)
        'patientName': _patientNameController.text.trim(),
        'patientAge': int.tryParse(_ageController.text.trim()) ?? 0,

        // Clinical details
        'symptoms': _symptomsController.text.trim(),
        'diagnosis': _diagnosisController.text.trim(),
        'advice': _adviceController.text.trim(),

        // Medicines
        'medicines': meds,

        // Meta
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Persist to /doctors/{doctorId}/prescriptions/{prescriptionId}
      await newDoc.set(data);
      print(
        '✅ Prescription saved to /doctors/$doctorId/prescriptions/$prescriptionId',
      );

      // Also mirror under /users/{docWithFullNamePatient3}/prescriptions/{prescriptionId}
      try {
        const targetFullName = 'Rajesh Kumar';
        final usersQuery = await FirebaseFirestore.instance
            .collection('users')
            .where('fullName', isEqualTo: targetFullName)
            .limit(1)
            .get();

        if (usersQuery.docs.isNotEmpty) {
          final patientDocId = usersQuery.docs.first.id;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(patientDocId)
              .collection('prescriptions')
              .doc(prescriptionId)
              .set({
                ...data,
                'mirroredFrom': 'doctors/$doctorId',
                'mirroredAt': FieldValue.serverTimestamp(),
              });
          print(
            '✅ Prescription mirrored to /users/'
            '$patientDocId/prescriptions/$prescriptionId',
          );
        } else {
          print(
            '⚠️ No user document found with fullName == $targetFullName; skipping mirror',
          );
        }
      } catch (mirrorError) {
        // Do not block main flow if mirror fails
        print('⚠️ Mirror save failed (query by fullName): $mirrorError');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Prescription saved for ${_patientNameController.text}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Show success dialog with an option to go back
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Prescription Saved'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patient: ${_patientNameController.text}'),
                const SizedBox(height: 6),
                Text('ID: $prescriptionId'),
                const SizedBox(height: 12),
                const Text(
                  'You can view this later in your prescriptions list.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving prescription: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAddMedicineDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _AddMedicineDialog(
          commonMedicines: _commonMedicines,
          onAdd: (medicine) {
            setState(() {
              _medicines.add(medicine);
            });
          },
        );
      },
    );
  }

  void _removeMedicine(int index) {
    setState(() {
      _medicines.removeAt(index);
    });
  }
}

class _AddMedicineDialog extends StatefulWidget {
  final List<String> commonMedicines;
  final Function(Medicine) onAdd;

  const _AddMedicineDialog({
    required this.commonMedicines,
    required this.onAdd,
  });

  @override
  State<_AddMedicineDialog> createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends State<_AddMedicineDialog> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();

  String? _selectedMedicine;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Medicine',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Medicine Selection
            DropdownButtonFormField<String>(
              initialValue: _selectedMedicine,
              decoration: const InputDecoration(
                labelText: 'Medicine Name',
                border: OutlineInputBorder(),
              ),
              items: widget.commonMedicines.map((medicine) {
                return DropdownMenuItem(value: medicine, child: Text(medicine));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMedicine = value;
                  _nameController.text = value ?? '';
                });
              },
            ),

            const SizedBox(height: 16),

            // Custom medicine name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Or enter custom medicine',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosage (1-1-1)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                hintText: 'e.g., After food',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty &&
                        _dosageController.text.isNotEmpty &&
                        _durationController.text.isNotEmpty) {
                      final medicine = Medicine(
                        name: _nameController.text,
                        dosage: _dosageController.text,
                        duration: _durationController.text,
                        instructions: _instructionsController.text,
                      );
                      widget.onAdd(medicine);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Medicine {
  final String name;
  final String dosage;
  final String duration;
  final String instructions;

  Medicine({
    required this.name,
    required this.dosage,
    required this.duration,
    required this.instructions,
  });
}

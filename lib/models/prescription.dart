class Prescription {
  final String prescriptionId;
  final String doctorId;
  final String patientId;
  final String appointmentId;
  final String doctorName;
  final String patientName;
  final String patientAge;
  final String patientGender;
  final String diagnosis;
  final List<Medicine> medicines;
  final String status; // pending, accepted, filled, cancelled
  final String? pharmacyId;
  final String? pharmacyName;
  final DateTime issuedAt;
  final DateTime? acceptedAt;
  final DateTime? filledAt;
  final Map<String, dynamic> additionalInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription({
    required this.prescriptionId,
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    required this.doctorName,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.diagnosis,
    required this.medicines,
    this.status = 'pending',
    this.pharmacyId,
    this.pharmacyName,
    required this.issuedAt,
    this.acceptedAt,
    this.filledAt,
    this.additionalInstructions = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      prescriptionId: map['prescriptionId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      patientId: map['patientId'] ?? '',
      appointmentId: map['appointmentId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      patientName: map['patientName'] ?? '',
      patientAge: map['patientAge'] ?? '',
      patientGender: map['patientGender'] ?? '',
      diagnosis: map['diagnosis'] ?? '',
      medicines: (map['medicines'] as List<dynamic>?)
          ?.map((m) => Medicine.fromMap(m as Map<String, dynamic>))
          .toList() ?? [],
      status: map['status'] ?? 'pending',
      pharmacyId: map['pharmacyId'],
      pharmacyName: map['pharmacyName'],
      issuedAt: (map['issuedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      acceptedAt: (map['acceptedAt'] as dynamic)?.toDate(),
      filledAt: (map['filledAt'] as dynamic)?.toDate(),
      additionalInstructions: Map<String, dynamic>.from(map['additionalInstructions'] ?? {}),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prescriptionId': prescriptionId,
      'doctorId': doctorId,
      'patientId': patientId,
      'appointmentId': appointmentId,
      'doctorName': doctorName,
      'patientName': patientName,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'diagnosis': diagnosis,
      'medicines': medicines.map((m) => m.toMap()).toList(),
      'status': status,
      'pharmacyId': pharmacyId,
      'pharmacyName': pharmacyName,
      'issuedAt': issuedAt,
      'acceptedAt': acceptedAt,
      'filledAt': filledAt,
      'additionalInstructions': additionalInstructions,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Medicine {
  final String medicineName;
  final String genericName;
  final String dosage;
  final String frequency;
  final int duration; // in days
  final int quantity;
  final String instructions;
  final String medicineType; // tablet, syrup, injection, etc.
  final bool isGenericAllowed;

  Medicine({
    required this.medicineName,
    required this.genericName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.quantity,
    required this.instructions,
    this.medicineType = 'tablet',
    this.isGenericAllowed = true,
  });

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      medicineName: map['medicineName'] ?? '',
      genericName: map['genericName'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      duration: map['duration'] ?? 0,
      quantity: map['quantity'] ?? 0,
      instructions: map['instructions'] ?? '',
      medicineType: map['medicineType'] ?? 'tablet',
      isGenericAllowed: map['isGenericAllowed'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'genericName': genericName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'quantity': quantity,
      'instructions': instructions,
      'medicineType': medicineType,
      'isGenericAllowed': isGenericAllowed,
    };
  }
}
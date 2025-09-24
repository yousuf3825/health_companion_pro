class Doctor {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String specialty;
  final String qualification;
  final String experience;
  final String registrationNumber;
  final String clinicName;
  final String clinicAddress;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final List<String> consultationTypes;
  final double consultationFee;
  final String profileImageUrl;
  final List<String> certificates;
  final double rating;
  final int totalConsultations;
  final int totalRatings;
  final bool isActive;
  final bool isVerified;
  final String availabilityStatus;
  final Map<String, dynamic> workingHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.qualification,
    required this.experience,
    required this.registrationNumber,
    required this.clinicName,
    required this.clinicAddress,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.consultationTypes,
    required this.consultationFee,
    this.profileImageUrl = '',
    this.certificates = const [],
    this.rating = 0.0,
    this.totalConsultations = 0,
    this.totalRatings = 0,
    this.isActive = true,
    this.isVerified = false,
    this.availabilityStatus = 'available',
    this.workingHours = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      specialty: map['specialty'] ?? '',
      qualification: map['qualification'] ?? '',
      experience: map['experience'] ?? '',
      registrationNumber: map['registrationNumber'] ?? '',
      clinicName: map['clinicName'] ?? '',
      clinicAddress: map['clinicAddress'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      consultationTypes: List<String>.from(map['consultationTypes'] ?? []),
      consultationFee: (map['consultationFee'] ?? 0.0).toDouble(),
      profileImageUrl: map['profileImageUrl'] ?? '',
      certificates: List<String>.from(map['certificates'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalConsultations: map['totalConsultations'] ?? 0,
      totalRatings: map['totalRatings'] ?? 0,
      isActive: map['isActive'] ?? true,
      isVerified: map['isVerified'] ?? false,
      availabilityStatus: map['availabilityStatus'] ?? 'available',
      workingHours: Map<String, dynamic>.from(map['workingHours'] ?? {}),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'specialty': specialty,
      'qualification': qualification,
      'experience': experience,
      'registrationNumber': registrationNumber,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'consultationTypes': consultationTypes,
      'consultationFee': consultationFee,
      'profileImageUrl': profileImageUrl,
      'certificates': certificates,
      'rating': rating,
      'totalConsultations': totalConsultations,
      'totalRatings': totalRatings,
      'isActive': isActive,
      'isVerified': isVerified,
      'availabilityStatus': availabilityStatus,
      'workingHours': workingHours,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Doctor copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? specialty,
    String? qualification,
    String? experience,
    String? registrationNumber,
    String? clinicName,
    String? clinicAddress,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
    List<String>? consultationTypes,
    double? consultationFee,
    String? profileImageUrl,
    List<String>? certificates,
    double? rating,
    int? totalConsultations,
    int? totalRatings,
    bool? isActive,
    bool? isVerified,
    String? availabilityStatus,
    Map<String, dynamic>? workingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialty: specialty ?? this.specialty,
      qualification: qualification ?? this.qualification,
      experience: experience ?? this.experience,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      consultationTypes: consultationTypes ?? this.consultationTypes,
      consultationFee: consultationFee ?? this.consultationFee,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      certificates: certificates ?? this.certificates,
      rating: rating ?? this.rating,
      totalConsultations: totalConsultations ?? this.totalConsultations,
      totalRatings: totalRatings ?? this.totalRatings,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      workingHours: workingHours ?? this.workingHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
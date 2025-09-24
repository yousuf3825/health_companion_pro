class Pharmacy {
  final String uid;
  final String pharmacyName;
  final String ownerName;
  final String email;
  final String phone;
  final String licenseNumber;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final double latitude;
  final double longitude;
  final List<String> services;
  final String profileImageUrl;
  final List<String> certificates;
  final double rating;
  final int totalOrders;
  final int totalRatings;
  final bool isActive;
  final bool isVerified;
  final String operationalStatus;
  final double deliveryRadius;
  final Map<String, dynamic> workingHours;
  final bool homeDelivery;
  final double deliveryFee;
  final DateTime createdAt;
  final DateTime updatedAt;

  Pharmacy({
    required this.uid,
    required this.pharmacyName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.services,
    this.profileImageUrl = '',
    this.certificates = const [],
    this.rating = 0.0,
    this.totalOrders = 0,
    this.totalRatings = 0,
    this.isActive = true,
    this.isVerified = false,
    this.operationalStatus = 'open',
    this.deliveryRadius = 10.0,
    this.workingHours = const {},
    this.homeDelivery = true,
    this.deliveryFee = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pharmacy.fromMap(Map<String, dynamic> map) {
    return Pharmacy(
      uid: map['uid'] ?? '',
      pharmacyName: map['pharmacyName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      services: List<String>.from(map['services'] ?? []),
      profileImageUrl: map['profileImageUrl'] ?? '',
      certificates: List<String>.from(map['certificates'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalOrders: map['totalOrders'] ?? 0,
      totalRatings: map['totalRatings'] ?? 0,
      isActive: map['isActive'] ?? true,
      isVerified: map['isVerified'] ?? false,
      operationalStatus: map['operationalStatus'] ?? 'open',
      deliveryRadius: (map['deliveryRadius'] ?? 10.0).toDouble(),
      workingHours: Map<String, dynamic>.from(map['workingHours'] ?? {}),
      homeDelivery: map['homeDelivery'] ?? true,
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'pharmacyName': pharmacyName,
      'ownerName': ownerName,
      'email': email,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'services': services,
      'profileImageUrl': profileImageUrl,
      'certificates': certificates,
      'rating': rating,
      'totalOrders': totalOrders,
      'totalRatings': totalRatings,
      'isActive': isActive,
      'isVerified': isVerified,
      'operationalStatus': operationalStatus,
      'deliveryRadius': deliveryRadius,
      'workingHours': workingHours,
      'homeDelivery': homeDelivery,
      'deliveryFee': deliveryFee,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Pharmacy copyWith({
    String? uid,
    String? pharmacyName,
    String? ownerName,
    String? email,
    String? phone,
    String? licenseNumber,
    String? address,
    String? city,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
    List<String>? services,
    String? profileImageUrl,
    List<String>? certificates,
    double? rating,
    int? totalOrders,
    int? totalRatings,
    bool? isActive,
    bool? isVerified,
    String? operationalStatus,
    double? deliveryRadius,
    Map<String, dynamic>? workingHours,
    bool? homeDelivery,
    double? deliveryFee,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pharmacy(
      uid: uid ?? this.uid,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      services: services ?? this.services,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      certificates: certificates ?? this.certificates,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      totalRatings: totalRatings ?? this.totalRatings,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      operationalStatus: operationalStatus ?? this.operationalStatus,
      deliveryRadius: deliveryRadius ?? this.deliveryRadius,
      workingHours: workingHours ?? this.workingHours,
      homeDelivery: homeDelivery ?? this.homeDelivery,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
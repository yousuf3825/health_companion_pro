# Firebase User Management Implementation

## Overview
This implementation provides role-based user registration and management for MedConnect Pro, storing doctor and pharmacy profiles in organized Firebase Firestore collections.

## Firebase Structure

### Main Structure (New Implementation)
```
users/
  ├── doctors/
  │   └── profiles/
  │       ├── {userId1} (Doctor Profile)
  │       ├── {userId2} (Doctor Profile)
  │       └── ...
  ├── pharmacies/
  │   └── profiles/
  │       ├── {userId1} (Pharmacy Profile)
  │       ├── {userId2} (Pharmacy Profile)
  │       └── ...
  └── {userId} (User Lookup Document)
```

### Legacy Structure (Maintained for Backward Compatibility)
```
doctors/
  ├── {userId1} (Doctor Profile)
  ├── {userId2} (Doctor Profile)
  └── ...
pharmacies/
  ├── {userId1} (Pharmacy Profile)
  ├── {userId2} (Pharmacy Profile)
  └── ...
```

## User Data Structure

### Doctor Profile
```json
{
  "uid": "user123",
  "role": "doctor",
  "name": "Dr. John Smith",
  "email": "doctor@example.com",
  "phoneNumber": "+1234567890",
  "licenseNumber": "DOC123456",
  "specialty": "Cardiologist",
  "qualification": "MBBS, MD",
  "experience": "5 years",
  "hospital": "City Hospital",
  "consultationFee": 500,
  "availableHours": "9 AM - 5 PM",
  "rating": 4.5,
  "totalConsultations": 0,
  "isActive": true,
  "isVerified": false,
  "profileComplete": true,
  "createdAt": "2024-01-01T10:00:00Z",
  "updatedAt": "2024-01-01T10:00:00Z",
  "registrationDate": "2024-01-01T10:00:00Z"
}
```

### Pharmacy Profile
```json
{
  "uid": "user456",
  "role": "pharmacy",
  "name": "John Doe",
  "email": "pharmacy@example.com",
  "phoneNumber": "+1234567890",
  "licenseNumber": "PHARM789",
  "pharmacyName": "City Pharmacy",
  "ownerName": "John Doe",
  "gstNumber": "GST123456789",
  "address": "123 Main St, City",
  "city": "New York",
  "state": "NY",
  "pincode": "10001",
  "operatingHours": "9 AM - 9 PM",
  "deliveryAvailable": true,
  "rating": 4.0,
  "totalOrders": 0,
  "isActive": true,
  "isVerified": false,
  "profileComplete": true,
  "createdAt": "2024-01-01T10:00:00Z",
  "updatedAt": "2024-01-01T10:00:00Z",
  "registrationDate": "2024-01-01T10:00:00Z"
}
```

### User Lookup Document
```json
{
  "uid": "user123",
  "role": "doctor",
  "name": "Dr. John Smith",
  "email": "doctor@example.com",
  "phoneNumber": "+1234567890",
  "profilePath": "users/doctors/profiles/user123",
  "createdAt": "2024-01-01T10:00:00Z",
  "isActive": true
}
```

## Key Features

### 1. Role-Based Registration
- Automatically creates user profiles in appropriate collections based on role
- Maintains both new structured format and legacy collections
- Handles role-specific fields and validation

### 2. Dual Storage System
- **Primary**: `users/doctors/profiles/` and `users/pharmacies/profiles/`
- **Secondary**: `doctors/` and `pharmacies/` (for backward compatibility)
- **Lookup**: `users/{userId}` for quick role identification

### 3. Enhanced Profile Management
- Comprehensive doctor profiles with specialization, ratings, and consultation data
- Detailed pharmacy profiles with location, delivery options, and inventory data
- Automatic timestamp management for creation and updates

### 4. Error Handling
- Graceful fallback to temporary registration when Firebase has issues
- Comprehensive error logging and user feedback
- Support for both Firebase Auth and local storage backup

## API Methods

### Core Authentication
- `signUpWithEmailAndPassword()` - Register new users with role-based profile creation
- `signInWithEmailAndPassword()` - Authenticate users and load profiles
- `signOut()` - Sign out and clear local data

### Profile Management
- `createUserProfile()` - Create user profiles in Firebase
- `getUserProfile()` - Retrieve user profiles with fallback support
- `updateUserProfile()` - Update profiles in both new and legacy structures
- `getAllDoctors()` - Fetch all active doctor profiles
- `getAllPharmacies()` - Fetch all active pharmacy profiles

### Utility Methods
- `testFirebaseStructure()` - Verify Firebase collections are accessible
- `resetPassword()` - Send password reset emails
- `deleteAccount()` - Remove user accounts and associated data

## Usage Example

```dart
// Register a new doctor
final result = await AuthService.signUpWithEmailAndPassword(
  email: 'doctor@example.com',
  password: 'password123',
  role: 'doctor',
  profileData: {
    'name': 'Dr. John Smith',
    'phoneNumber': '+1234567890',
    'licenseNumber': 'DOC123456',
    'specialty': 'Cardiologist',
    'qualification': 'MBBS, MD',
    'experience': '5 years',
    'hospital': 'City Hospital',
  },
);

// Get all doctors
List<Map<String, dynamic>> doctors = await AuthService.getAllDoctors();

// Update user profile
bool success = await AuthService.updateUserProfile(
  userId: 'user123',
  role: 'doctor',
  updates: {
    'availableHours': '10 AM - 6 PM',
    'consultationFee': 600,
  },
);
```

## Security Features
- Server-side timestamps for accurate record keeping
- Admin verification required (`isVerified: false` by default)
- Active/inactive user management
- Comprehensive error logging for monitoring

## Migration Notes
- New users automatically use the structured format
- Existing users continue to work with legacy collections
- Profile retrieval attempts new structure first, falls back to legacy
- All updates maintain both structures for seamless transition
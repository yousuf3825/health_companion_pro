import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class DoctorService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Create doctor profile
  static Future<void> createDoctorProfile({
    required String doctorId,
    required Map<String, dynamic> doctorData,
  }) async {
    try {
      await FirebaseService.doctors.doc(doctorId).set({
        ...doctorData,
        'uid': doctorId,
        'role': 'doctor',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isVerified': false,
        'rating': 0.0,
        'totalConsultations': 0,
        'totalRatings': 0,
        'availabilityStatus': 'available', // available, busy, offline
      });
    } catch (e) {
      print('Create doctor profile error: $e');
      throw e;
    }
  }

  // Get doctor profile
  static Future<Map<String, dynamic>?> getDoctorProfile(String doctorId) async {
    try {
      DocumentSnapshot doc = await FirebaseService.doctors.doc(doctorId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Get doctor profile error: $e');
      throw e;
    }
  }

  // Update doctor profile
  static Future<void> updateDoctorProfile({
    required String doctorId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await FirebaseService.doctors.doc(doctorId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update doctor profile error: $e');
      throw e;
    }
  }

  // Create time slot
  static Future<void> createTimeSlot({
    required String doctorId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required bool isAvailable,
  }) async {
    try {
      String slotId = '${doctorId}_${date.millisecondsSinceEpoch}_${startTime.replaceAll(':', '')}';
      
      await FirebaseService.getDoctorSlots(doctorId).doc(slotId).set({
        'slotId': slotId,
        'doctorId': doctorId,
        'date': Timestamp.fromDate(date),
        'startTime': startTime,
        'endTime': endTime,
        'isAvailable': isAvailable,
        'isBooked': false,
        'patientId': null,
        'appointmentId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Also create in global slots collection for easy searching
      await FirebaseService.slots.doc(slotId).set({
        'slotId': slotId,
        'doctorId': doctorId,
        'date': Timestamp.fromDate(date),
        'startTime': startTime,
        'endTime': endTime,
        'isAvailable': isAvailable,
        'isBooked': false,
        'patientId': null,
        'appointmentId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Create time slot error: $e');
      throw e;
    }
  }

  // Get doctor slots
  static Stream<QuerySnapshot> getDoctorSlots(String doctorId) {
    return FirebaseService.getDoctorSlots(doctorId)
        .orderBy('date')
        .orderBy('startTime')
        .snapshots();
  }

  // Get available slots for a date
  static Future<List<Map<String, dynamic>>> getAvailableSlots({
    required String doctorId,
    required DateTime date,
  }) async {
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      QuerySnapshot snapshot = await FirebaseService.getDoctorSlots(doctorId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('isAvailable', isEqualTo: true)
          .where('isBooked', isEqualTo: false)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      }).toList();
    } catch (e) {
      print('Get available slots error: $e');
      throw e;
    }
  }

  // Create appointment
  static Future<String> createAppointment({
    required String doctorId,
    required String patientId,
    required String slotId,
    required Map<String, dynamic> appointmentData,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      // Create appointment
      DocumentReference appointmentRef = FirebaseService.appointments.doc();
      batch.set(appointmentRef, {
        ...appointmentData,
        'appointmentId': appointmentRef.id,
        'doctorId': doctorId,
        'patientId': patientId,
        'slotId': slotId,
        'status': 'scheduled', // scheduled, completed, cancelled
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update slot as booked
      batch.update(FirebaseService.getDoctorSlots(doctorId).doc(slotId), {
        'isBooked': true,
        'patientId': patientId,
        'appointmentId': appointmentRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also update global slot
      batch.update(FirebaseService.slots.doc(slotId), {
        'isBooked': true,
        'patientId': patientId,
        'appointmentId': appointmentRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add to doctor's appointments
      batch.set(FirebaseService.getDoctorAppointments(doctorId).doc(appointmentRef.id), {
        ...appointmentData,
        'appointmentId': appointmentRef.id,
        'doctorId': doctorId,
        'patientId': patientId,
        'slotId': slotId,
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return appointmentRef.id;
    } catch (e) {
      print('Create appointment error: $e');
      throw e;
    }
  }

  // Get doctor appointments
  static Stream<QuerySnapshot> getDoctorAppointments(String doctorId) {
    return FirebaseService.getDoctorAppointments(doctorId)
        .orderBy('scheduledDate', descending: true)
        .snapshots();
  }

  // Create prescription
  static Future<String> createPrescription({
    required String doctorId,
    required String patientId,
    required String appointmentId,
    required List<Map<String, dynamic>> medicines,
    required Map<String, dynamic> prescriptionData,
  }) async {
    try {
      DocumentReference prescriptionRef = FirebaseService.prescriptions.doc();
      
      Map<String, dynamic> prescription = {
        ...prescriptionData,
        'prescriptionId': prescriptionRef.id,
        'doctorId': doctorId,
        'patientId': patientId,
        'appointmentId': appointmentId,
        'medicines': medicines,
        'status': 'pending', // pending, filled, cancelled
        'issuedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      WriteBatch batch = _firestore.batch();
      
      // Create global prescription
      batch.set(prescriptionRef, prescription);
      
      // Add to doctor's prescriptions
      batch.set(
        FirebaseService.getDoctorPrescriptions(doctorId).doc(prescriptionRef.id),
        prescription,
      );

      await batch.commit();
      return prescriptionRef.id;
    } catch (e) {
      print('Create prescription error: $e');
      throw e;
    }
  }

  // Get doctor prescriptions
  static Stream<QuerySnapshot> getDoctorPrescriptions(String doctorId) {
    return FirebaseService.getDoctorPrescriptions(doctorId)
        .orderBy('issuedAt', descending: true)
        .snapshots();
  }

  // Update appointment status
  static Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (additionalData != null) {
        updates.addAll(additionalData);
      }

      await FirebaseService.appointments.doc(appointmentId).update(updates);
    } catch (e) {
      print('Update appointment status error: $e');
      throw e;
    }
  }

  // Search doctors by specialty or location
  static Future<List<Map<String, dynamic>>> searchDoctors({
    String? specialty,
    String? location,
    int limit = 20,
  }) async {
    try {
      Query query = FirebaseService.doctors
          .where('isActive', isEqualTo: true)
          .where('isVerified', isEqualTo: true);

      if (specialty != null && specialty.isNotEmpty) {
        query = query.where('specialty', isEqualTo: specialty);
      }

      if (location != null && location.isNotEmpty) {
        query = query.where('city', isEqualTo: location);
      }

      QuerySnapshot snapshot = await query.limit(limit).get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      }).toList();
    } catch (e) {
      print('Search doctors error: $e');
      throw e;
    }
  }
}
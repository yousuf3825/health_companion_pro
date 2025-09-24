import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class PharmacyService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Create pharmacy profile
  static Future<void> createPharmacyProfile({
    required String pharmacyId,
    required Map<String, dynamic> pharmacyData,
  }) async {
    try {
      await FirebaseService.pharmacies.doc(pharmacyId).set({
        ...pharmacyData,
        'uid': pharmacyId,
        'role': 'pharmacy',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isVerified': false,
        'rating': 0.0,
        'totalOrders': 0,
        'totalRatings': 0,
        'operationalStatus': 'open', // open, closed, busy
        'deliveryRadius': 10.0, // in kilometers
      });
    } catch (e) {
      print('Create pharmacy profile error: $e');
      throw e;
    }
  }

  // Get pharmacy profile
  static Future<Map<String, dynamic>?> getPharmacyProfile(String pharmacyId) async {
    try {
      DocumentSnapshot doc = await FirebaseService.pharmacies.doc(pharmacyId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Get pharmacy profile error: $e');
      throw e;
    }
  }

  // Update pharmacy profile
  static Future<void> updatePharmacyProfile({
    required String pharmacyId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await FirebaseService.pharmacies.doc(pharmacyId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update pharmacy profile error: $e');
      throw e;
    }
  }

  // Add medicine to inventory
  static Future<void> addMedicineToInventory({
    required String pharmacyId,
    required Map<String, dynamic> medicineData,
  }) async {
    try {
      String medicineId = medicineData['medicineId'] ?? _firestore.collection('temp').doc().id;
      
      await FirebaseService.getPharmacyInventory(pharmacyId).doc(medicineId).set({
        ...medicineData,
        'medicineId': medicineId,
        'pharmacyId': pharmacyId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Also add to global medicines collection for searching
      await FirebaseService.medicines.doc(medicineId).set({
        ...medicineData,
        'medicineId': medicineId,
        'pharmacyId': pharmacyId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      print('Add medicine to inventory error: $e');
      throw e;
    }
  }

  // Get pharmacy inventory
  static Stream<QuerySnapshot> getPharmacyInventory(String pharmacyId) {
    return FirebaseService.getPharmacyInventory(pharmacyId)
        .where('isActive', isEqualTo: true)
        .orderBy('medicineName')
        .snapshots();
  }

  // Update medicine stock
  static Future<void> updateMedicineStock({
    required String pharmacyId,
    required String medicineId,
    required int newStock,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      Map<String, dynamic> updates = {
        'stock': newStock,
        'isAvailable': newStock > 0,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update in pharmacy inventory
      batch.update(
        FirebaseService.getPharmacyInventory(pharmacyId).doc(medicineId),
        updates,
      );

      // Update in global medicines collection
      batch.update(FirebaseService.medicines.doc(medicineId), updates);

      await batch.commit();
    } catch (e) {
      print('Update medicine stock error: $e');
      throw e;
    }
  }

  // Get incoming prescriptions
  static Stream<QuerySnapshot> getIncomingPrescriptions(String pharmacyId) {
    return FirebaseService.prescriptions
        .where('status', isEqualTo: 'pending')
        .orderBy('issuedAt', descending: true)
        .snapshots();
  }

  // Accept prescription and create order
  static Future<String> acceptPrescription({
    required String pharmacyId,
    required String prescriptionId,
    required List<Map<String, dynamic>> availableMedicines,
    required double totalAmount,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      // Create order
      DocumentReference orderRef = FirebaseService.orders.doc();
      Map<String, dynamic> orderData = {
        'orderId': orderRef.id,
        'prescriptionId': prescriptionId,
        'pharmacyId': pharmacyId,
        'medicines': availableMedicines,
        'totalAmount': totalAmount,
        'status': 'accepted', // accepted, preparing, ready, delivered, cancelled
        'paymentStatus': 'pending', // pending, paid, failed
        'deliveryStatus': 'pending', // pending, dispatched, delivered
        'orderType': 'prescription',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      batch.set(orderRef, orderData);

      // Update prescription status
      batch.update(FirebaseService.prescriptions.doc(prescriptionId), {
        'status': 'accepted',
        'pharmacyId': pharmacyId,
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add to pharmacy orders
      batch.set(
        FirebaseService.getPharmacyOrders(pharmacyId).doc(orderRef.id),
        orderData,
      );

      await batch.commit();
      return orderRef.id;
    } catch (e) {
      print('Accept prescription error: $e');
      throw e;
    }
  }

  // Get pharmacy orders
  static Stream<QuerySnapshot> getPharmacyOrders(String pharmacyId) {
    return FirebaseService.getPharmacyOrders(pharmacyId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update order status
  static Future<void> updateOrderStatus({
    required String orderId,
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

      await FirebaseService.orders.doc(orderId).update(updates);
    } catch (e) {
      print('Update order status error: $e');
      throw e;
    }
  }

  // Search medicines
  static Future<List<Map<String, dynamic>>> searchMedicines({
    required String query,
    String? pharmacyId,
    bool availableOnly = true,
    int limit = 20,
  }) async {
    try {
      Query medicineQuery = FirebaseService.medicines
          .where('isActive', isEqualTo: true);

      if (pharmacyId != null) {
        medicineQuery = medicineQuery.where('pharmacyId', isEqualTo: pharmacyId);
      }

      if (availableOnly) {
        medicineQuery = medicineQuery.where('isAvailable', isEqualTo: true);
      }

      // For now, we'll get all medicines and filter locally
      // In production, you'd want to implement proper text search
      QuerySnapshot snapshot = await medicineQuery.limit(limit * 2).get();
      
      List<Map<String, dynamic>> medicines = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              })
          .where((medicine) => 
              medicine['medicineName']?.toString().toLowerCase().contains(query.toLowerCase()) == true ||
              medicine['genericName']?.toString().toLowerCase().contains(query.toLowerCase()) == true ||
              medicine['manufacturer']?.toString().toLowerCase().contains(query.toLowerCase()) == true)
          .take(limit)
          .toList();

      return medicines;
    } catch (e) {
      print('Search medicines error: $e');
      throw e;
    }
  }

  // Check medicine availability for prescription
  static Future<Map<String, dynamic>> checkPrescriptionAvailability({
    required String pharmacyId,
    required List<Map<String, dynamic>> prescriptionMedicines,
  }) async {
    try {
      List<Map<String, dynamic>> availableMedicines = [];
      List<Map<String, dynamic>> unavailableMedicines = [];
      double totalAmount = 0.0;

      for (Map<String, dynamic> prescriptionMedicine in prescriptionMedicines) {
        String medicineName = prescriptionMedicine['medicineName'];
        int requiredQuantity = prescriptionMedicine['quantity'] ?? 1;

        // Search in pharmacy inventory
        QuerySnapshot inventorySnapshot = await FirebaseService
            .getPharmacyInventory(pharmacyId)
            .where('medicineName', isEqualTo: medicineName)
            .where('isAvailable', isEqualTo: true)
            .limit(1)
            .get();

        if (inventorySnapshot.docs.isNotEmpty) {
          Map<String, dynamic> medicine = inventorySnapshot.docs.first.data() as Map<String, dynamic>;
          int availableStock = medicine['stock'] ?? 0;

          if (availableStock >= requiredQuantity) {
            Map<String, dynamic> availableMedicine = {
              ...prescriptionMedicine,
              'medicineId': medicine['medicineId'],
              'unitPrice': medicine['unitPrice'] ?? 0.0,
              'totalPrice': (medicine['unitPrice'] ?? 0.0) * requiredQuantity,
              'availableStock': availableStock,
            };
            
            availableMedicines.add(availableMedicine);
            totalAmount += availableMedicine['totalPrice'];
          } else {
            unavailableMedicines.add({
              ...prescriptionMedicine,
              'reason': 'Insufficient stock (Available: $availableStock)',
            });
          }
        } else {
          unavailableMedicines.add({
            ...prescriptionMedicine,
            'reason': 'Medicine not available in inventory',
          });
        }
      }

      return {
        'availableMedicines': availableMedicines,
        'unavailableMedicines': unavailableMedicines,
        'totalAmount': totalAmount,
        'canFulfill': unavailableMedicines.isEmpty,
        'partialFulfillment': availableMedicines.isNotEmpty && unavailableMedicines.isNotEmpty,
      };
    } catch (e) {
      print('Check prescription availability error: $e');
      throw e;
    }
  }

  // Search nearby pharmacies
  static Future<List<Map<String, dynamic>>> searchNearbyPharmacies({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int limit = 20,
  }) async {
    try {
      // Note: For production, you'd want to use GeoFirestore for proper geospatial queries
      // For now, we'll get all active pharmacies and filter locally
      QuerySnapshot snapshot = await FirebaseService.pharmacies
          .where('isActive', isEqualTo: true)
          .where('isVerified', isEqualTo: true)
          .where('operationalStatus', isEqualTo: 'open')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>
      }).toList();
    } catch (e) {
      print('Search nearby pharmacies error: $e');
      throw e;
    }
  }
}
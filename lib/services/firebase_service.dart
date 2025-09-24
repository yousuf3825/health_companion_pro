import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Request notification permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
  }

  // Authentication
  static FirebaseAuth get auth => _auth;
  static User? get currentUser => _auth.currentUser;

  // Firestore
  static FirebaseFirestore get firestore => _firestore;
  
  // Storage
  static FirebaseStorage get storage => _storage;
  
  // Messaging
  static FirebaseMessaging get messaging => _messaging;

  // Get FCM Token
  static Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }

  // Collections references
  static CollectionReference get doctors => _firestore.collection('doctors');
  static CollectionReference get pharmacies => _firestore.collection('pharmacies');
  static CollectionReference get patients => _firestore.collection('patients');
  static CollectionReference get prescriptions => _firestore.collection('prescriptions');
  static CollectionReference get appointments => _firestore.collection('appointments');
  static CollectionReference get orders => _firestore.collection('orders');
  static CollectionReference get medicines => _firestore.collection('medicines');
  static CollectionReference get slots => _firestore.collection('slots');

  // Doctor specific collections
  static CollectionReference getDoctorAppointments(String doctorId) =>
      doctors.doc(doctorId).collection('appointments');
  
  static CollectionReference getDoctorSlots(String doctorId) =>
      doctors.doc(doctorId).collection('slots');
  
  static CollectionReference getDoctorPrescriptions(String doctorId) =>
      doctors.doc(doctorId).collection('prescriptions');

  // Pharmacy specific collections
  static CollectionReference getPharmacyOrders(String pharmacyId) =>
      pharmacies.doc(pharmacyId).collection('orders');
  
  static CollectionReference getPharmacyInventory(String pharmacyId) =>
      pharmacies.doc(pharmacyId).collection('inventory');
  
  static CollectionReference getPharmacyPrescriptions(String pharmacyId) =>
      pharmacies.doc(pharmacyId).collection('prescriptions');

  // Patient specific collections
  static CollectionReference getPatientAppointments(String patientId) =>
      patients.doc(patientId).collection('appointments');
  
  static CollectionReference getPatientPrescriptions(String patientId) =>
      patients.doc(patientId).collection('prescriptions');
  
  static CollectionReference getPatientOrders(String patientId) =>
      patients.doc(patientId).collection('orders');
}
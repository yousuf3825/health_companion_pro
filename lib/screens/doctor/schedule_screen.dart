import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Appointment> _appointments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('🏥 Schedule Screen: Page visited - initializing');
    _fetchQueueData();
  }

  Future<void> _fetchQueueData() async {
    print('📊 Schedule Screen: Starting to fetch queue data...');
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user.uid)
          .collection('queue')
          .orderBy('createdAt', descending: true)
          .get();

      final List<Appointment> fetchedAppointments = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        // Extract patient details
        final patientDetails =
            data['patientDetails'] as Map<String, dynamic>? ?? {};
        final patientName =
            patientDetails['name']?.toString() ?? 'Unknown Patient';
        final patientPhone =
            patientDetails['phoneNumber']?.toString() ?? 'No phone';
        final patientAge = patientDetails['age']?.toString() ?? '';
        final patientGender = patientDetails['gender']?.toString() ?? '';

        // Get other appointment details
        final category = data['category']?.toString() ?? 'General Consultation';
        final estimatedTime = data['estimatedTime']?.toString() ?? 'Now';
        final status = _mapFirebaseStatusToAppointmentStatus(
          data['status']?.toString() ?? 'waiting',
        );
        final token = data['token']?.toString() ?? '';
        final priority = data['priority']?.toString() ?? 'normal';

        // Format time display
        String timeDisplay = estimatedTime;
        if (estimatedTime.toLowerCase() == 'now') {
          timeDisplay = 'Now';
        }

        // Create patient info string
        String patientInfo = patientName;
        if (patientAge.isNotEmpty || patientGender.isNotEmpty) {
          List<String> details = [];
          if (patientAge.isNotEmpty) details.add('${patientAge}y');
          if (patientGender.isNotEmpty) details.add(patientGender);
          patientInfo += ' (${details.join(', ')})';
        }

        fetchedAppointments.add(
          Appointment(
            id: doc.id,
            patientName: patientInfo,
            time: timeDisplay,
            duration: '30 min', // Default duration
            type: category,
            status: status,
            phone: patientPhone,
            token: token,
            priority: priority,
          ),
        );
      }

      setState(() {
        _appointments = fetchedAppointments;
        _loading = false;
      });

      print(
        '✅ Schedule Screen: Successfully fetched ${fetchedAppointments.length} appointments from queue',
      );
    } catch (e) {
      print('❌ Schedule Screen: Error fetching queue data - $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  AppointmentStatus _mapFirebaseStatusToAppointmentStatus(
    String firebaseStatus,
  ) {
    switch (firebaseStatus.toLowerCase()) {
      case 'waiting':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchQueueData,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(_selectedDate),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _loading
                      ? 'Loading appointments...'
                      : '${_appointments.length} patients in queue',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Quick Stats
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Queue',
                    count: _appointments.length,
                    color: Colors.blue,
                    icon: Icons.people,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Waiting',
                    count: _appointments
                        .where((a) => a.status == AppointmentStatus.pending)
                        .length,
                    color: Colors.orange,
                    icon: Icons.hourglass_empty,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Urgent',
                    count: _appointments
                        .where((a) => a.priority == 'high')
                        .length,
                    color: Colors.red,
                    icon: Icons.priority_high,
                  ),
                ),
              ],
            ),
          ),

          // Appointments List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading queue',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchQueueData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _appointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No patients in queue',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your queue is empty for now',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchQueueData,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _appointments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(
                                appointment.status,
                              ).withValues(alpha: 0.1),
                              child: appointment.token.isNotEmpty
                                  ? Text(
                                      appointment.token,
                                      style: TextStyle(
                                        color: _getStatusColor(
                                          appointment.status,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Icon(
                                      _getStatusIcon(appointment.status),
                                      color: _getStatusColor(
                                        appointment.status,
                                      ),
                                    ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    appointment.patientName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (appointment.priority == 'high')
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'URGENT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(appointment.status),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getStatusText(appointment.status),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text('Expected: ${appointment.time}'),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.medical_services,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(appointment.type)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(appointment.phone),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) =>
                                  _handleAppointmentAction(appointment, value),
                              itemBuilder: (context) => [
                                if (appointment.status ==
                                    AppointmentStatus.pending)
                                  const PopupMenuItem(
                                    value: 'call',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.video_call,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Start Consultation'),
                                      ],
                                    ),
                                  ),
                                const PopupMenuItem(
                                  value: 'details',
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline),
                                      SizedBox(width: 8),
                                      Text('View Details'),
                                    ],
                                  ),
                                ),
                                if (appointment.status ==
                                    AppointmentStatus.pending)
                                  const PopupMenuItem(
                                    value: 'reschedule',
                                    child: Row(
                                      children: [
                                        Icon(Icons.schedule),
                                        SizedBox(width: 8),
                                        Text('Reschedule'),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];

    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.completed:
        return Colors.blue;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.pending:
        return Icons.pending;
      case AppointmentStatus.completed:
        return Icons.done_all;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return 'CONFIRMED';
      case AppointmentStatus.pending:
        return 'PENDING';
      case AppointmentStatus.completed:
        return 'COMPLETED';
      case AppointmentStatus.cancelled:
        return 'CANCELLED';
    }
  }

  void _handleAppointmentAction(Appointment appointment, String action) {
    switch (action) {
      case 'call':
        Navigator.pushNamed(context, '/join-call');
        break;
      case 'details':
        _showPatientDetails(appointment);
        break;
      case 'reschedule':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reschedule functionality')),
        );
        break;
    }
  }

  void _showPatientDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Patient Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${appointment.patientName}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Phone: ${appointment.phone}'),
            SizedBox(height: 8),
            Text('Category: ${appointment.type}'),
            SizedBox(height: 8),
            Text('Expected Time: ${appointment.time}'),
            if (appointment.token.isNotEmpty) ...[
              SizedBox(height: 8),
              Text('Token: ${appointment.token}'),
            ],
            SizedBox(height: 8),
            Text('Status: ${_getStatusText(appointment.status)}'),
            if (appointment.priority == 'high') ...[
              SizedBox(height: 8),
              Text(
                'Priority: HIGH',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          if (appointment.status == AppointmentStatus.pending)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/join-call');
              },
              child: Text('Start Consultation'),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

enum AppointmentStatus { confirmed, pending, completed, cancelled }

class Appointment {
  final String id;
  final String patientName;
  final String time;
  final String duration;
  final String type;
  final AppointmentStatus status;
  final String phone;
  final String token;
  final String priority;

  Appointment({
    required this.id,
    required this.patientName,
    required this.time,
    required this.duration,
    required this.type,
    required this.status,
    required this.phone,
    this.token = '',
    this.priority = 'normal',
  });
}

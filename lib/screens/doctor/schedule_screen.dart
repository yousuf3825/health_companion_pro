import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  final List<Appointment> _appointments = [
    Appointment(
      id: '1',
      patientName: 'Rajesh Kumar',
      time: '10:00 AM',
      duration: '30 min',
      type: 'General Consultation',
      status: AppointmentStatus.confirmed,
      phone: '+91 98765 43210',
    ),
    Appointment(
      id: '2',
      patientName: 'Priya Sharma',
      time: '10:30 AM',
      duration: '30 min',
      type: 'Follow-up',
      status: AppointmentStatus.confirmed,
      phone: '+91 98765 43211',
    ),
    Appointment(
      id: '3',
      patientName: 'Amit Singh',
      time: '11:00 AM',
      duration: '30 min',
      type: 'General Consultation',
      status: AppointmentStatus.pending,
      phone: '+91 98765 43212',
    ),
    Appointment(
      id: '4',
      patientName: 'Sunita Patel',
      time: '2:00 PM',
      duration: '30 min',
      type: 'Urgent Consultation',
      status: AppointmentStatus.confirmed,
      phone: '+91 98765 43213',
    ),
    Appointment(
      id: '5',
      patientName: 'Vikram Gupta',
      time: '2:30 PM',
      duration: '30 min',
      type: 'General Consultation',
      status: AppointmentStatus.completed,
      phone: '+91 98765 43214',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
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
                  '${_appointments.length} appointments scheduled',
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
                    title: 'Total',
                    count: _appointments.length,
                    color: Colors.blue,
                    icon: Icons.event,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Confirmed',
                    count:
                        _appointments
                            .where(
                              (a) => a.status == AppointmentStatus.confirmed,
                            )
                            .length,
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Pending',
                    count:
                        _appointments
                            .where((a) => a.status == AppointmentStatus.pending)
                            .length,
                    color: Colors.orange,
                    icon: Icons.pending,
                  ),
                ),
              ],
            ),
          ),

          // Appointments List
          Expanded(
            child:
                _appointments.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No appointments scheduled',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your schedule is free for today',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
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
                              ).withOpacity(0.1),
                              child: Icon(
                                _getStatusIcon(appointment.status),
                                color: _getStatusColor(appointment.status),
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
                                    Text(
                                      '${appointment.time} (${appointment.duration})',
                                    ),
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
                              onSelected:
                                  (value) => _handleAppointmentAction(
                                    appointment,
                                    value,
                                  ),
                              itemBuilder:
                                  (context) => [
                                    if (appointment.status !=
                                        AppointmentStatus.completed)
                                      const PopupMenuItem(
                                        value: 'start',
                                        child: Row(
                                          children: [
                                            Icon(Icons.video_call),
                                            SizedBox(width: 8),
                                            Text('Start Call'),
                                          ],
                                        ),
                                      ),
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
                                    const PopupMenuItem(
                                      value: 'cancel',
                                      child: Row(
                                        children: [
                                          Icon(Icons.cancel),
                                          SizedBox(width: 8),
                                          Text('Cancel'),
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
      case 'start':
        Navigator.pushNamed(context, '/join-call');
        break;
      case 'reschedule':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reschedule functionality')),
        );
        break;
      case 'cancel':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Appointment cancelled')));
        break;
    }
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

  Appointment({
    required this.id,
    required this.patientName,
    required this.time,
    required this.duration,
    required this.type,
    required this.status,
    required this.phone,
  });
}

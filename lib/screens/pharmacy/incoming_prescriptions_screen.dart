import 'package:flutter/material.dart';

class IncomingPrescriptionsScreen extends StatefulWidget {
  const IncomingPrescriptionsScreen({super.key});

  @override
  State<IncomingPrescriptionsScreen> createState() =>
      _IncomingPrescriptionsScreenState();
}

class _IncomingPrescriptionsScreenState
    extends State<IncomingPrescriptionsScreen> {
  final List<PrescriptionOrder> _prescriptions = [
    PrescriptionOrder(
      id: 'RX001',
      patientName: 'Rajesh Kumar',
      doctorName: 'Dr. Smith',
      prescribedDate: DateTime.now().subtract(const Duration(hours: 2)),
      medicines: [
        PrescribedMedicine(
          name: 'Paracetamol 500mg',
          dosage: '1-1-1',
          duration: '5 days',
          available: true,
        ),
        PrescribedMedicine(
          name: 'Amoxicillin 250mg',
          dosage: '1-0-1',
          duration: '7 days',
          available: true,
        ),
      ],
      status: PrescriptionStatus.pending,
      priority: PrescriptionPriority.normal,
    ),
    PrescriptionOrder(
      id: 'RX002',
      patientName: 'Priya Sharma',
      doctorName: 'Dr. Johnson',
      prescribedDate: DateTime.now().subtract(const Duration(hours: 4)),
      medicines: [
        PrescribedMedicine(
          name: 'Ibuprofen 400mg',
          dosage: '1-0-1',
          duration: '3 days',
          available: false,
        ),
        PrescribedMedicine(
          name: 'Cough Syrup',
          dosage: '5ml TID',
          duration: '5 days',
          available: true,
        ),
        PrescribedMedicine(
          name: 'Vitamin D3',
          dosage: '1-0-0',
          duration: '30 days',
          available: true,
        ),
      ],
      status: PrescriptionStatus.processing,
      priority: PrescriptionPriority.urgent,
    ),
    PrescriptionOrder(
      id: 'RX003',
      patientName: 'Amit Singh',
      doctorName: 'Dr. Brown',
      prescribedDate: DateTime.now().subtract(const Duration(hours: 6)),
      medicines: [
        PrescribedMedicine(
          name: 'Omeprazole 20mg',
          dosage: '1-0-0',
          duration: '14 days',
          available: true,
        ),
        PrescribedMedicine(
          name: 'Iron Tablets',
          dosage: '0-0-1',
          duration: '30 days',
          available: true,
        ),
      ],
      status: PrescriptionStatus.ready,
      priority: PrescriptionPriority.normal,
    ),
    PrescriptionOrder(
      id: 'RX004',
      patientName: 'Sunita Patel',
      doctorName: 'Dr. Davis',
      prescribedDate: DateTime.now().subtract(const Duration(days: 1)),
      medicines: [
        PrescribedMedicine(
          name: 'Calcium Tablets',
          dosage: '1-0-1',
          duration: '30 days',
          available: true,
        ),
      ],
      status: PrescriptionStatus.dispensed,
      priority: PrescriptionPriority.normal,
    ),
  ];

  PrescriptionStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final filteredPrescriptions =
        _selectedFilter == null
            ? _prescriptions
            : _prescriptions.where((p) => p.status == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Prescriptions'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Stats
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Pending',
                    count:
                        _prescriptions
                            .where(
                              (p) => p.status == PrescriptionStatus.pending,
                            )
                            .length,
                    color: Colors.orange,
                    icon: Icons.pending_actions,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Processing',
                    count:
                        _prescriptions
                            .where(
                              (p) => p.status == PrescriptionStatus.processing,
                            )
                            .length,
                    color: Colors.blue,
                    icon: Icons.refresh,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Ready',
                    count:
                        _prescriptions
                            .where((p) => p.status == PrescriptionStatus.ready)
                            .length,
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          if (_selectedFilter != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Chip(
                    label: Text('Filter: ${_getStatusText(_selectedFilter!)}'),
                    onDeleted: () {
                      setState(() {
                        _selectedFilter = null;
                      });
                    },
                    deleteIcon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),

          // Prescriptions List
          Expanded(
            child:
                filteredPrescriptions.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == null
                                ? 'No prescriptions available'
                                : 'No ${_getStatusText(_selectedFilter!).toLowerCase()} prescriptions',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPrescriptions.length,
                      itemBuilder: (context, index) {
                        final prescription = filteredPrescriptions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _getStatusColor(
                                    prescription.status,
                                  ).withOpacity(0.1),
                                  child: Icon(
                                    _getStatusIcon(prescription.status),
                                    color: _getStatusColor(prescription.status),
                                  ),
                                ),
                                if (prescription.priority ==
                                    PrescriptionPriority.urgent)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prescription.id,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        prescription.patientName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          prescription.status,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getStatusText(prescription.status),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (prescription.priority ==
                                        PrescriptionPriority.urgent)
                                      const Text(
                                        'URGENT',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(prescription.doctorName),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatTime(prescription.prescribedDate),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.medical_services,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${prescription.medicines.length} medicines',
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      prescription.medicines.every(
                                            (m) => m.available,
                                          )
                                          ? Icons.check_circle
                                          : Icons.warning,
                                      size: 14,
                                      color:
                                          prescription.medicines.every(
                                                (m) => m.available,
                                              )
                                              ? Colors.green
                                              : Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      prescription.medicines.every(
                                            (m) => m.available,
                                          )
                                          ? 'All available'
                                          : 'Some unavailable',
                                      style: TextStyle(
                                        color:
                                            prescription.medicines.every(
                                                  (m) => m.available,
                                                )
                                                ? Colors.green
                                                : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Prescribed Medicines:',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ...prescription.medicines.map(
                                      (medicine) => Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color:
                                              medicine.available
                                                  ? Colors.green[50]
                                                  : Colors.red[50],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color:
                                                medicine.available
                                                    ? Colors.green[200]!
                                                    : Colors.red[200]!,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              medicine.available
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color:
                                                  medicine.available
                                                      ? Colors.green
                                                      : Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    medicine.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${medicine.dosage} • ${medicine.duration}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (!medicine.available)
                                              TextButton(
                                                onPressed: () {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Alternative for ${medicine.name}',
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  'Find Alternative',
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        if (prescription.status ==
                                            PrescriptionStatus.pending)
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed:
                                                  () => _updateStatus(
                                                    prescription,
                                                    PrescriptionStatus
                                                        .processing,
                                                  ),
                                              icon: const Icon(
                                                Icons.play_arrow,
                                              ),
                                              label: const Text(
                                                'Start Processing',
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        if (prescription.status ==
                                            PrescriptionStatus.processing) ...[
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed:
                                                  () => _updateStatus(
                                                    prescription,
                                                    PrescriptionStatus.ready,
                                                  ),
                                              icon: const Icon(Icons.done),
                                              label: const Text('Mark Ready'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (prescription.status ==
                                            PrescriptionStatus.ready) ...[
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed:
                                                  () => _updateStatus(
                                                    prescription,
                                                    PrescriptionStatus
                                                        .dispensed,
                                                  ),
                                              icon: const Icon(
                                                Icons.local_shipping,
                                              ),
                                              label: const Text(
                                                'Mark Dispensed',
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Prescriptions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                PrescriptionStatus.values.map((status) {
                  return ListTile(
                    title: Text(_getStatusText(status)),
                    onTap: () {
                      setState(() {
                        _selectedFilter = status;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedFilter = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Clear Filter'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _updateStatus(
    PrescriptionOrder prescription,
    PrescriptionStatus newStatus,
  ) {
    setState(() {
      prescription.status = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${prescription.id} status updated to ${_getStatusText(newStatus)}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
    }
  }

  Color _getStatusColor(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.pending:
        return Colors.orange;
      case PrescriptionStatus.processing:
        return Colors.blue;
      case PrescriptionStatus.ready:
        return Colors.green;
      case PrescriptionStatus.dispensed:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.pending:
        return Icons.pending_actions;
      case PrescriptionStatus.processing:
        return Icons.refresh;
      case PrescriptionStatus.ready:
        return Icons.check_circle;
      case PrescriptionStatus.dispensed:
        return Icons.local_shipping;
    }
  }

  String _getStatusText(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.pending:
        return 'Pending';
      case PrescriptionStatus.processing:
        return 'Processing';
      case PrescriptionStatus.ready:
        return 'Ready';
      case PrescriptionStatus.dispensed:
        return 'Dispensed';
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

enum PrescriptionStatus { pending, processing, ready, dispensed }

enum PrescriptionPriority { normal, urgent }

class PrescriptionOrder {
  final String id;
  final String patientName;
  final String doctorName;
  final DateTime prescribedDate;
  final List<PrescribedMedicine> medicines;
  PrescriptionStatus status;
  final PrescriptionPriority priority;

  PrescriptionOrder({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.prescribedDate,
    required this.medicines,
    required this.status,
    required this.priority,
  });
}

class PrescribedMedicine {
  final String name;
  final String dosage;
  final String duration;
  final bool available;

  PrescribedMedicine({
    required this.name,
    required this.dosage,
    required this.duration,
    required this.available,
  });
}

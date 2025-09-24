import 'package:flutter/material.dart';
import '../models/app_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDoctor = AppState.currentRole == UserRole.doctor;
    final userName =
        isDoctor
            ? AppState.currentUserName ?? 'Doctor'
            : AppState.currentPharmacyName ?? 'Pharmacy';

    return Scaffold(
      appBar: AppBar(
        title: Text('SehatLink Pro'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Card
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDoctor
                          ? 'Welcome, Dr. $userName'
                          : 'Welcome, $userName',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isDoctor
                          ? 'Ready to help your patients today'
                          : 'Manage prescriptions and inventory',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Quick Stats
            Text(
              'Quick Stats',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _StatsCard(
                    title:
                        isDoctor ? 'Today\'s Appointments' : 'Pending Orders',
                    value: isDoctor ? '12' : '8',
                    icon:
                        isDoctor ? Icons.calendar_today : Icons.pending_actions,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatsCard(
                    title: isDoctor ? 'Prescriptions' : 'Completed Orders',
                    value: isDoctor ? '45' : '23',
                    icon: isDoctor ? Icons.description : Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Main Actions
            Text(
              'Main Actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            if (isDoctor)
              ..._buildDoctorActions(context)
            else
              ..._buildPharmacyActions(context),

            const SizedBox(height: 32),

            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        isDoctor ? Icons.person : Icons.shopping_bag,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      isDoctor
                          ? 'Consultation with Patient ${String.fromCharCode(65 + index)}'
                          : 'Order #${1001 + index} processed',
                    ),
                    subtitle: Text('${2 + index} hours ago'),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDoctorActions(BuildContext context) {
    final actions = [
      {
        'title': 'Slot Setup',
        'subtitle': 'Configure your available time slots',
        'icon': Icons.schedule,
        'color': Colors.purple,
        'route': '/slot-setup',
      },
      {
        'title': 'Schedule',
        'subtitle': 'View today\'s appointments',
        'icon': Icons.calendar_month,
        'color': Colors.blue,
        'route': '/schedule',
      },
      {
        'title': 'Join Call',
        'subtitle': 'Start video consultation',
        'icon': Icons.video_call,
        'color': Colors.orange,
        'route': '/join-call',
      },
      {
        'title': 'Prescriptions',
        'subtitle': 'Create and manage prescriptions',
        'icon': Icons.description,
        'color': Colors.green,
        'route': '/prescription',
      },
    ];

    return actions
        .map(
          (action) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ActionCard(
              title: action['title'] as String,
              subtitle: action['subtitle'] as String,
              icon: action['icon'] as IconData,
              color: action['color'] as Color,
              onTap:
                  () => Navigator.pushNamed(context, action['route'] as String),
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildPharmacyActions(BuildContext context) {
    final actions = [
      {
        'title': 'Incoming Prescriptions',
        'subtitle': 'View new prescription requests',
        'icon': Icons.receipt_long,
        'color': Colors.blue,
        'route': '/incoming-prescriptions',
      },
      {
        'title': 'Medicine Availability',
        'subtitle': 'Manage your inventory',
        'icon': Icons.inventory,
        'color': Colors.purple,
        'route': '/medicine-availability',
      },
      {
        'title': 'Orders & Deliveries',
        'subtitle': 'Track orders and deliveries',
        'icon': Icons.local_shipping,
        'color': Colors.orange,
        'route': '/orders-deliveries',
      },
    ];

    return actions
        .map(
          (action) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ActionCard(
              title: action['title'] as String,
              subtitle: action['subtitle'] as String,
              icon: action['icon'] as IconData,
              color: action['color'] as Color,
              onTap:
                  () => Navigator.pushNamed(context, action['route'] as String),
            ),
          ),
        )
        .toList();
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/debug_helper.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedConnect Pro'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              await DebugHelper.checkUserDataConsistency();
              // Check if we need to create missing profile
              final appState = Provider.of<AppState>(context, listen: false);
              if (appState.currentUserName == null && appState.currentPharmacyName == null) {
                await DebugHelper.createMissingUserProfile(
                  name: 'Pharmacy', 
                  role: 'pharmacy',
                  pharmacyName: 'Pharmacy',
                );
                // Reinitialize user data
                await appState.initializeUser();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with user info and stats
                _buildHeader(context, appState),
                
                const SizedBox(height: 20),

                // Main functionality cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (appState.isDoctor)
                        _buildDoctorView(context),
                      if (appState.isPharmacy)
                        _buildPharmacyView(context),
                      if (appState.currentRole == null)
                        _buildWelcomeView(context),

                      const SizedBox(height: 24),

                      // Recent Activity Section
                      Text(
                        'Recent Activity',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRecentActivity(context, appState),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState) {
    final isDoctor = appState.isDoctor;
    final userName = isDoctor 
        ? appState.currentUserName ?? 'Doctor'
        : appState.currentPharmacyName ?? 'Pharmacy';
    
    // Debug logging
    print('Dashboard - User Role: ${appState.currentRole}');
    print('Dashboard - User ID: ${appState.currentUserId}');
    print('Dashboard - User Name: ${appState.currentUserName}');
    print('Dashboard - Pharmacy Name: ${appState.currentPharmacyName}');
    print('Dashboard - Is Doctor: $isDoctor');
    print('Dashboard - Display Name: $userName');
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    isDoctor ? 'DR' : userName.substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        isDoctor ? 'Dr. $userName' : userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isDoctor ? 'Medical Professional' : 'Pharmacy',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Stats cards
            Row(
              children: [
                if (isDoctor) ...[
                  _buildStatCard('Today\'s\nAppointments', '8', Icons.calendar_today),
                  const SizedBox(width: 12),
                  _buildStatCard('Patients\nServed', '156', Icons.people),
                  const SizedBox(width: 12),
                  _buildStatCard('Prescriptions\nWritten', '24', Icons.receipt),
                ] else ...[
                  _buildStatCard('Orders\nToday', '12', Icons.shopping_bag),
                  const SizedBox(width: 12),
                  _buildStatCard('Medicines\nDispensed', '89', Icons.medication),
                  const SizedBox(width: 12),
                  _buildStatCard('Revenue\nToday', '₹5.2K', Icons.currency_rupee),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorView(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildActionCard(
          context,
          'Appointments',
          Icons.calendar_today,
          'Manage your appointments',
          Colors.blue,
          () => Navigator.pushNamed(context, '/schedule'),
        ),
        _buildActionCard(
          context,
          'Patients',
          Icons.people,
          'View patient records',
          Colors.green,
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patients feature coming soon')),
          ),
        ),
        _buildActionCard(
          context,
          'Prescriptions',
          Icons.receipt,
          'Write prescriptions',
          Colors.orange,
          () => Navigator.pushNamed(context, '/prescription'),
        ),
        _buildActionCard(
          context,
          'Video Calls',
          Icons.video_call,
          'Start consultation',
          Colors.purple,
          () => Navigator.pushNamed(context, '/join-call'),
        ),
        _buildActionCard(
          context,
          'Schedule',
          Icons.schedule,
          'Set available slots',
          Colors.teal,
          () => Navigator.pushNamed(context, '/slot-setup'),
        ),
        _buildActionCard(
          context,
          'Reports',
          Icons.analytics,
          'View analytics',
          Colors.indigo,
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reports feature coming soon')),
          ),
        ),
      ],
    );
  }

  Widget _buildPharmacyView(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildActionCard(
          context,
          'Inventory',
          Icons.inventory_2,
          'Manage medicines',
          Colors.blue,
          () => Navigator.pushNamed(context, '/medicine-availability'),
        ),
        _buildActionCard(
          context,
          'Orders',
          Icons.shopping_bag,
          'View pending orders',
          Colors.green,
          () => Navigator.pushNamed(context, '/orders-deliveries'),
        ),
        _buildActionCard(
          context,
          'Prescriptions',
          Icons.receipt,
          'Incoming prescriptions',
          Colors.orange,
          () => Navigator.pushNamed(context, '/incoming-prescriptions'),
        ),
        _buildActionCard(
          context,
          'Delivery',
          Icons.local_shipping,
          'Track deliveries',
          Colors.purple,
          () => Navigator.pushNamed(context, '/orders-deliveries'),
        ),
        _buildActionCard(
          context,
          'Sales',
          Icons.point_of_sale,
          'Daily sales report',
          Colors.teal,
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sales feature coming soon')),
          ),
        ),
        _buildActionCard(
          context,
          'Analytics',
          Icons.analytics,
          'Business insights',
          Colors.indigo,
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Analytics feature coming soon')),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeView(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_add,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Complete Your Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please complete your profile setup to access all features',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                child: const Text('Setup Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, AppState appState) {
    final isDoctor = appState.isDoctor;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Activities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('View all activities')),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isDoctor) ...[
              _buildActivityItem(
                Icons.person,
                'Patient consultation',
                'John Doe - 10:30 AM',
                'Completed',
                Colors.green,
              ),
              _buildActivityItem(
                Icons.calendar_today,
                'Next appointment',
                'Sarah Johnson - 2:00 PM',
                'Upcoming',
                Colors.orange,
              ),
              _buildActivityItem(
                Icons.receipt,
                'Prescription written',
                'Antibiotics for throat infection',
                '30 min ago',
                Colors.blue,
              ),
            ] else ...[
              _buildActivityItem(
                Icons.shopping_bag,
                'New order received',
                'Prescription #PX1234 - ₹450',
                'Processing',
                Colors.orange,
              ),
              _buildActivityItem(
                Icons.local_shipping,
                'Delivery completed',
                'Order #OD5678 to Rajesh Kumar',
                'Delivered',
                Colors.green,
              ),
              _buildActivityItem(
                Icons.inventory,
                'Stock updated',
                'Paracetamol - 200 units added',
                '1 hour ago',
                Colors.blue,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    String title,
    String subtitle,
    String status,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
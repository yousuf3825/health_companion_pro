import 'package:flutter/material.dart';

class OrdersDeliveriesScreen extends StatefulWidget {
  const OrdersDeliveriesScreen({super.key});

  @override
  State<OrdersDeliveriesScreen> createState() => _OrdersDeliveriesScreenState();
}

class _OrdersDeliveriesScreenState extends State<OrdersDeliveriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Order> _orders = [
    Order(
      id: 'ORD001',
      patientName: 'Rajesh Kumar',
      prescriptionId: 'RX001',
      items: [
        OrderItem(medicineName: 'Paracetamol 500mg', quantity: 10, price: 50.0),
        OrderItem(
          medicineName: 'Amoxicillin 250mg',
          quantity: 21,
          price: 262.5,
        ),
      ],
      totalAmount: 312.5,
      orderDate: DateTime.now().subtract(const Duration(hours: 1)),
      status: OrderStatus.confirmed,
      deliveryAddress: '123 Main St, City Center, Pin: 400001',
      phoneNumber: '+91 98765 43210',
      paymentMethod: 'Cash on Delivery',
    ),
    Order(
      id: 'ORD002',
      patientName: 'Priya Sharma',
      prescriptionId: 'RX002',
      items: [
        OrderItem(medicineName: 'Cough Syrup', quantity: 1, price: 25.0),
        OrderItem(medicineName: 'Vitamin D3', quantity: 30, price: 600.0),
      ],
      totalAmount: 625.0,
      orderDate: DateTime.now().subtract(const Duration(hours: 3)),
      status: OrderStatus.preparing,
      deliveryAddress: '456 Park Avenue, Suburb, Pin: 400002',
      phoneNumber: '+91 98765 43211',
      paymentMethod: 'UPI',
    ),
    Order(
      id: 'ORD003',
      patientName: 'Amit Singh',
      prescriptionId: 'RX003',
      items: [
        OrderItem(medicineName: 'Omeprazole 20mg', quantity: 14, price: 210.0),
        OrderItem(medicineName: 'Iron Tablets', quantity: 30, price: 660.0),
      ],
      totalAmount: 870.0,
      orderDate: DateTime.now().subtract(const Duration(hours: 5)),
      status: OrderStatus.outForDelivery,
      deliveryAddress: '789 Hill Road, Downtown, Pin: 400003',
      phoneNumber: '+91 98765 43212',
      paymentMethod: 'Card',
    ),
    Order(
      id: 'ORD004',
      patientName: 'Sunita Patel',
      prescriptionId: 'RX004',
      items: [
        OrderItem(medicineName: 'Calcium Tablets', quantity: 60, price: 1080.0),
      ],
      totalAmount: 1080.0,
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.delivered,
      deliveryAddress: '321 Beach Road, Coastal Area, Pin: 400004',
      phoneNumber: '+91 98765 43213',
      paymentMethod: 'Cash on Delivery',
    ),
    Order(
      id: 'ORD005',
      patientName: 'Vikram Gupta',
      prescriptionId: 'RX005',
      items: [
        OrderItem(medicineName: 'Cetirizine 10mg', quantity: 10, price: 100.0),
        OrderItem(medicineName: 'Paracetamol 500mg', quantity: 10, price: 50.0),
      ],
      totalAmount: 150.0,
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      status: OrderStatus.cancelled,
      deliveryAddress: '654 Garden Street, Green Valley, Pin: 400005',
      phoneNumber: '+91 98765 43214',
      paymentMethod: 'UPI',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Order> get pendingOrders {
    return _orders
        .where(
          (order) =>
              order.status == OrderStatus.confirmed ||
              order.status == OrderStatus.preparing ||
              order.status == OrderStatus.outForDelivery,
        )
        .toList();
  }

  List<Order> get completedOrders {
    return _orders
        .where(
          (order) =>
              order.status == OrderStatus.delivered ||
              order.status == OrderStatus.cancelled,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders & Deliveries'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'Pending (${pendingOrders.length})',
              icon: const Icon(Icons.pending_actions),
            ),
            Tab(
              text: 'Completed (${completedOrders.length})',
              icon: const Icon(Icons.done_all),
            ),
          ],
        ),
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
                    title: 'Total Orders',
                    count: _orders.length,
                    color: Colors.blue,
                    icon: Icons.shopping_bag,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Delivered',
                    count:
                        _orders
                            .where((o) => o.status == OrderStatus.delivered)
                            .length,
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Revenue',
                    count: _orders
                        .where((o) => o.status == OrderStatus.delivered)
                        .fold(
                          0,
                          (sum, order) => sum + order.totalAmount.toInt(),
                        ),
                    color: Colors.purple,
                    icon: Icons.currency_rupee,
                    prefix: '₹',
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(pendingOrders, isPending: true),
                _buildOrdersList(completedOrders, isPending: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, {required bool isPending}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending ? Icons.inbox_outlined : Icons.done_all_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isPending ? 'No pending orders' : 'No completed orders',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.id,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            order.patientName,
                            style: const TextStyle(
                              fontSize: 16,
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
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(order.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${order.totalAmount.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Order Details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Items (${order.items.length}):',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.medicineName} × ${item.quantity}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                '₹${item.price.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Order Info
                Row(
                  children: [
                    Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Prescription: ${order.prescriptionId}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(order.orderDate),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      order.paymentMethod,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      order.phoneNumber,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action Buttons
                if (isPending) _buildActionButtons(order),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(Order order) {
    switch (order.status) {
      case OrderStatus.confirmed:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    () => _updateOrderStatus(order, OrderStatus.cancelled),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed:
                    () => _updateOrderStatus(order, OrderStatus.preparing),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Preparing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        );

      case OrderStatus.preparing:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                () => _updateOrderStatus(order, OrderStatus.outForDelivery),
            icon: const Icon(Icons.local_shipping),
            label: const Text('Mark Out for Delivery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        );

      case OrderStatus.outForDelivery:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _updateOrderStatus(order, OrderStatus.delivered),
            icon: const Icon(Icons.check),
            label: const Text('Mark as Delivered'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _updateOrderStatus(Order order, OrderStatus newStatus) {
    setState(() {
      order.status = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${order.id} status updated to ${_getStatusText(newStatus)}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.orange;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.preparing:
        return 'PREPARING';
      case OrderStatus.outForDelivery:
        return 'OUT FOR DELIVERY';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final String prefix;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              '$prefix${count.toString()}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

enum OrderStatus { confirmed, preparing, outForDelivery, delivered, cancelled }

class Order {
  final String id;
  final String patientName;
  final String prescriptionId;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  OrderStatus status;
  final String deliveryAddress;
  final String phoneNumber;
  final String paymentMethod;

  Order({
    required this.id,
    required this.patientName,
    required this.prescriptionId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    required this.deliveryAddress,
    required this.phoneNumber,
    required this.paymentMethod,
  });
}

class OrderItem {
  final String medicineName;
  final int quantity;
  final double price;

  OrderItem({
    required this.medicineName,
    required this.quantity,
    required this.price,
  });
}

import 'package:flutter/material.dart';

class MedicineAvailabilityScreen extends StatefulWidget {
  const MedicineAvailabilityScreen({super.key});

  @override
  State<MedicineAvailabilityScreen> createState() =>
      _MedicineAvailabilityScreenState();
}

class _MedicineAvailabilityScreenState
    extends State<MedicineAvailabilityScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  MedicineCategory? _selectedCategory;

  final List<Medicine> _medicines = [
    Medicine(
      name: 'Paracetamol 500mg',
      category: MedicineCategory.painkillers,
      stock: 150,
      minStock: 50,
      price: 5.0,
      available: true,
      expiryDate: DateTime.now().add(const Duration(days: 365)),
    ),
    Medicine(
      name: 'Amoxicillin 250mg',
      category: MedicineCategory.antibiotics,
      stock: 75,
      minStock: 30,
      price: 12.5,
      available: true,
      expiryDate: DateTime.now().add(const Duration(days: 180)),
    ),
    Medicine(
      name: 'Ibuprofen 400mg',
      category: MedicineCategory.painkillers,
      stock: 0,
      minStock: 25,
      price: 8.0,
      available: false,
      expiryDate: DateTime.now().add(const Duration(days: 200)),
    ),
    Medicine(
      name: 'Omeprazole 20mg',
      category: MedicineCategory.gastric,
      stock: 200,
      minStock: 40,
      price: 15.0,
      available: true,
      expiryDate: DateTime.now().add(const Duration(days: 300)),
    ),
    Medicine(
      name: 'Cough Syrup',
      category: MedicineCategory.syrups,
      stock: 45,
      minStock: 20,
      price: 25.0,
      available: true,
      expiryDate: DateTime.now().add(const Duration(days: 150)),
    ),
    Medicine(
      name: 'Vitamin D3',
      category: MedicineCategory.vitamins,
      stock: 100,
      minStock: 30,
      price: 20.0,
      available: true,
      expiryDate: DateTime.now().add(const Duration(days: 400)),
    ),
    Medicine(
      name: 'Calcium Tablets',
      category: MedicineCategory.vitamins,
      stock: 80,
      minStock: 25,
      price: 18.0,
      available: true,
      expiryDate: DateTime.now().add(const Duration(days: 350)),
    ),
    Medicine(
      name: 'Iron Tablets',
      category: MedicineCategory.vitamins,
      stock: 10,
      minStock: 20,
      price: 22.0,
      available: true,
      expiryDate: DateTime.now().add(const Duration(days: 250)),
    ),
    Medicine(
      name: 'Aspirin 75mg',
      category: MedicineCategory.painkillers,
      stock: 0,
      minStock: 40,
      price: 6.0,
      available: false,
      expiryDate: DateTime.now().add(const Duration(days: 280)),
    ),
    Medicine(
      name: 'Cetirizine 10mg',
      category: MedicineCategory.antihistamines,
      stock: 120,
      minStock: 35,
      price: 10.0,
      available: true,
      expiryDate: DateTime.now().add(const Duration(days: 320)),
    ),
  ];

  List<Medicine> get filteredMedicines {
    return _medicines.where((medicine) {
      final matchesSearch = medicine.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == null || medicine.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  int get availableCount => _medicines.where((m) => m.available).length;
  int get unavailableCount => _medicines.where((m) => !m.available).length;
  int get lowStockCount =>
      _medicines.where((m) => m.available && m.stock <= m.minStock).length;

  @override
  Widget build(BuildContext context) {
    final filtered = filteredMedicines;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Inventory'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMedicineDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Available',
                    count: availableCount,
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Out of Stock',
                    count: unavailableCount,
                    color: Colors.red,
                    icon: Icons.cancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Low Stock',
                    count: lowStockCount,
                    color: Colors.orange,
                    icon: Icons.warning,
                  ),
                ),
              ],
            ),
          ),

          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search medicines...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _CategoryChip(
                        label: 'All',
                        isSelected: _selectedCategory == null,
                        onTap: () {
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      ...MedicineCategory.values.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryChip(
                            label: _getCategoryName(category),
                            isSelected: _selectedCategory == category,
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Medicine List
          Expanded(
            child:
                filtered.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No medicines found for "$_searchQuery"'
                                : 'No medicines in this category',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final medicine = filtered[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            medicine.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _getCategoryName(medicine.category),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStockStatusColor(
                                              medicine,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            _getStockStatusText(medicine),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₹${medicine.price.toStringAsFixed(1)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Stock Information
                                Row(
                                  children: [
                                    Icon(
                                      Icons.inventory,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Stock: ${medicine.stock} units',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.warning_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Min: ${medicine.minStock}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.calendar_month,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Exp: ${_formatDate(medicine.expiryDate)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed:
                                            () => _showUpdateStockDialog(
                                              medicine,
                                            ),
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Update Stock'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Switch(
                                      value: medicine.available,
                                      onChanged: (value) {
                                        setState(() {
                                          medicine.available = value;
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${medicine.name} ${value ? 'marked as available' : 'marked as unavailable'}',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
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

  Color _getStockStatusColor(Medicine medicine) {
    if (!medicine.available || medicine.stock == 0) {
      return Colors.red;
    } else if (medicine.stock <= medicine.minStock) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getStockStatusText(Medicine medicine) {
    if (!medicine.available || medicine.stock == 0) {
      return 'OUT OF STOCK';
    } else if (medicine.stock <= medicine.minStock) {
      return 'LOW STOCK';
    } else {
      return 'IN STOCK';
    }
  }

  String _getCategoryName(MedicineCategory category) {
    switch (category) {
      case MedicineCategory.painkillers:
        return 'Pain Killers';
      case MedicineCategory.antibiotics:
        return 'Antibiotics';
      case MedicineCategory.vitamins:
        return 'Vitamins';
      case MedicineCategory.gastric:
        return 'Gastric';
      case MedicineCategory.syrups:
        return 'Syrups';
      case MedicineCategory.antihistamines:
        return 'Antihistamines';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showUpdateStockDialog(Medicine medicine) {
    final controller = TextEditingController(text: medicine.stock.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Stock - ${medicine.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Current stock: ${medicine.stock} units\nMinimum stock: ${medicine.minStock} units',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newStock = int.tryParse(controller.text) ?? 0;
                setState(() {
                  medicine.stock = newStock;
                  medicine.available = newStock > 0;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${medicine.name} stock updated to $newStock units',
                    ),
                  ),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMedicineDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add new medicine functionality')),
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
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

enum MedicineCategory {
  painkillers,
  antibiotics,
  vitamins,
  gastric,
  syrups,
  antihistamines,
}

class Medicine {
  final String name;
  final MedicineCategory category;
  int stock;
  final int minStock;
  final double price;
  bool available;
  final DateTime expiryDate;

  Medicine({
    required this.name,
    required this.category,
    required this.stock,
    required this.minStock,
    required this.price,
    required this.available,
    required this.expiryDate,
  });
}

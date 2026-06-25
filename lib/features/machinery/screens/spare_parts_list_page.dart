import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SparePartsListPage extends StatelessWidget {
  const SparePartsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spare Parts Inventory')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Search Parts',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          _buildPartCard(context, 'Oil Filter (Model-X)', 'PT-001', 12, 5, '₹1,200', Colors.green),
          _buildPartCard(context, 'Gasket Set (Borma)', 'PT-045', 2, 5, '₹800', Colors.red),
          _buildPartCard(context, 'Conveyor Belt (2m)', 'PT-102', 8, 2, '₹4,500', Colors.green),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('add_spare_part'),
        icon: const Icon(Icons.add),
        label: const Text('Add Part'),
      ),
    );
  }

  Widget _buildPartCard(BuildContext context, String name, String partNo, int qty, int minStock, String cost, Color stockColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.settings, color: Colors.grey),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Part#: $partNo • Cost: $cost\nMin Stock: $minStock'),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$qty', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: stockColor)),
            const Text('in stock', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}

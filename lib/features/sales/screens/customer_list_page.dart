import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCustomerCard(context, 'Premium Nuts Traders', 'Mumbai', 'Active', Colors.green, 45000.0),
          _buildCustomerCard(context, 'Global Snacks Corp', 'Dubai', 'Overdue', Colors.red, 123000.0),
          _buildCustomerCard(context, 'Local Wholesalers', 'Goa', 'Active', Colors.green, 0.0),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, String name, String city, String status, Color statusColor, double balance) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          child: Text(name[0], style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$city\nBalance: ₹ ${balance.toStringAsFixed(0)}'),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        onTap: () => context.goNamed('customer_detail'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sales_provider.dart';

class CreateSalesOrderPage extends ConsumerStatefulWidget {
  const CreateSalesOrderPage({super.key});

  @override
  ConsumerState<CreateSalesOrderPage> createState() => _CreateSalesOrderPageState();
}

class _CreateSalesOrderPageState extends ConsumerState<CreateSalesOrderPage> {
  String _customer = 'Premium Nuts Traders';
  final List<Map<String, dynamic>> _items = [];

  void _addItem() {
    setState(() {
      _items.add({'id': 'inv-123', 'grade': 'W320', 'quantity': 100, 'rate': 750.0}); // Added id and quantity instead of qty to match backend
    });
  }

  void _submit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Sales Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: $_customer'),
            Text('Total Items: ${_items.length}'),
            const SizedBox(height: 16),
            const Text('Are you sure you want to create this order?'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog

              double totalAmount = 0;
              for (var item in _items) {
                totalAmount += (item['quantity'] * item['rate']);
              }

              final success = await ref.read(salesProvider.notifier).createOrder({
                'customerId': 'cust-1', // Mocked ID
                'totalAmount': totalAmount,
                'inventoryItems': _items.map((i) => {'id': i['id'], 'quantity': i['quantity']}).toList(),
              });

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Created Successfully')));
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create order')));
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Sales Order')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _customer,
              decoration: const InputDecoration(labelText: 'Select Customer'),
              items: ['Premium Nuts Traders', 'Global Snacks Corp', 'Local Wholesalers']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _customer = v!),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Add Item')),
              ],
            ),
            const SizedBox(height: 8),
            if (_items.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No items added'))),
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: item['grade'],
                          decoration: const InputDecoration(labelText: 'Grade', contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                          items: ['W320', 'W240', 'W210', 'Splits']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => setState(() => _items[index]['grade'] = v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: item['quantity'].toString(),
                          decoration: const InputDecoration(labelText: 'Qty (kg)', contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(() => _items[index]['quantity'] = int.tryParse(v) ?? 0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: item['rate'].toString(),
                          decoration: const InputDecoration(labelText: 'Rate (₹)', contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(() => _items[index]['rate'] = double.tryParse(v) ?? 0.0),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _items.removeAt(index)),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _items.isEmpty ? null : _submit,
                child: const Text('Create Order', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

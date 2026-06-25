import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateSalesOrderPage extends StatefulWidget {
  const CreateSalesOrderPage({super.key});

  @override
  State<CreateSalesOrderPage> createState() => _CreateSalesOrderPageState();
}

class _CreateSalesOrderPageState extends State<CreateSalesOrderPage> {
  String _customer = 'Premium Nuts Traders';
  final List<Map<String, dynamic>> _items = [];

  void _addItem() {
    setState(() {
      _items.add({'grade': 'W320', 'qty': 100, 'rate': 750.0});
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Created Successfully')));
              context.pop();
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
                          initialValue: item['qty'].toString(),
                          decoration: const InputDecoration(labelText: 'Qty (kg)', contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(() => _items[index]['qty'] = int.tryParse(v) ?? 0),
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

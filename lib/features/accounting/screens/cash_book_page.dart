import 'package:flutter/material.dart';

class CashBookPage extends StatelessWidget {
  const CashBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Book'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Cash Balance:', style: TextStyle(fontSize: 16)),
                Text(
                  '₹ 45,000.00',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 10,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final isCashIn = index % 3 == 0;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCashIn ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                    child: Icon(
                      isCashIn ? Icons.south_west : Icons.north_east,
                      color: isCashIn ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(isCashIn ? 'Cash from ATM withdrawal' : 'Petty Cash Expense'),
                  subtitle: Text('2023-06-${15 - index}'),
                  trailing: Text(
                    isCashIn ? '+ ₹ 10,000' : '- ₹ 1,500',
                    style: TextStyle(
                      color: isCashIn ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show add cash entry dialog
          _showAddEntryDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Cash Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: 'Cash In',
              items: ['Cash In', 'Cash Out']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {},
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Save')),
        ],
      ),
    );
  }
}

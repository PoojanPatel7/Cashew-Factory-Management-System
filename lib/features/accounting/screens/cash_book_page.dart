import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/accounting_provider.dart';

class CashBookPage extends ConsumerWidget {
  const CashBookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountingState = ref.watch(accountingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Book'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(accountingProvider.notifier).fetchData(),
          ),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: accountingState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          final transactions = data['transactions'] as List<dynamic>? ?? [];
          final accounts = data['accounts'] as List<dynamic>? ?? [];

          // Find cash account balance
          final cashAccount = accounts.firstWhere(
            (a) => a['name']?.toString().toLowerCase().contains('cash') ?? false,
            orElse: () => {'balance': 0.0},
          );
          final cashBalance = cashAccount['balance'] ?? 0.0;

          // Filter transactions to those that involve the cash account
          final cashTransactions = transactions.where((t) {
            final debit = t['debitAccountId'];
            final credit = t['creditAccountId'];
            return debit == cashAccount['id'] || credit == cashAccount['id'];
          }).toList();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Cash Balance:', style: TextStyle(fontSize: 16)),
                    Text(
                      '₹ ${cashBalance.toStringAsFixed(2)}',
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
                child: cashTransactions.isEmpty
                    ? const Center(child: Text('No cash transactions found'))
                    : ListView.separated(
                        itemCount: cashTransactions.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final t = cashTransactions[index];
                          final amount = t['amount'] ?? 0.0;
                          final desc = t['description'] ?? 'Transaction';
                          final date = t['date']?.toString().split('T').first ?? 'Unknown';
                          
                          final isCashIn = t['debitAccountId'] == cashAccount['id'];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isCashIn ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                              child: Icon(
                                isCashIn ? Icons.south_west : Icons.north_east,
                                color: isCashIn ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(desc),
                            subtitle: Text(date),
                            trailing: Text(
                              isCashIn ? '+ ₹ $amount' : '- ₹ $amount',
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEntryDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context, WidgetRef ref) {
    String type = 'Cash In';
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Cash Entry'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: type,
                items: ['Cash In', 'Cash Out']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => type = v);
                },
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountCtrl,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final amt = double.tryParse(amountCtrl.text) ?? 0;
              if (amt <= 0) return;

              final debitId = type == 'Cash In' ? 'acc_cash' : 'acc_expense_misc';
              final creditId = type == 'Cash In' ? 'acc_revenue' : 'acc_cash';

              await ref.read(accountingProvider.notifier).logTransaction(
                description: descCtrl.text,
                debitAccountId: debitId,
                creditAccountId: creditId,
                amount: amt,
              );

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

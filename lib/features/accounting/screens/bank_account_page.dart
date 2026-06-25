import 'package:flutter/material.dart';

class BankAccountPage extends StatelessWidget {
  const BankAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Accounts'),
        actions: [
          IconButton(icon: const Icon(Icons.sync), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBankCard(context, 'HDFC Bank - Current', 'XXXX-XXXX-1234', 820000.0),
          _buildBankCard(context, 'SBI - OD Account', 'XXXX-XXXX-5678', -150000.0),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_business),
            label: const Text('Add Bank Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(BuildContext context, String bankName, String accNumber, double balance) {
    final isNegative = balance < 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(bankName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Icon(Icons.account_balance, color: Theme.of(context).colorScheme.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(accNumber, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 20),
            const Text('Available Balance'),
            Text(
              '₹ ${balance.abs().toStringAsFixed(2)}${isNegative ? ' (OD)' : ''}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isNegative ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('Statement'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.compare_arrows, size: 18),
                    label: const Text('Reconcile'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

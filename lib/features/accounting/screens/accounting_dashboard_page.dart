import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class AccountingDashboardPage extends StatelessWidget {
  const AccountingDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounting & Finance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAction(context, 'Ledger', Icons.book, 'ledger'),
                  _buildQuickAction(context, 'Expenses', Icons.money_off, 'expense_list'),
                  _buildQuickAction(context, 'Cash Book', Icons.account_balance_wallet, 'cash_book'),
                  _buildQuickAction(context, 'Bank A/c', Icons.account_balance, 'bank_account'),
                  _buildQuickAction(context, 'Trial Balance', Icons.balance, 'trial_balance'),
                  _buildQuickAction(context, 'GST', Icons.receipt_long, 'gst_dashboard'),
                  _buildQuickAction(context, 'P&L', Icons.insights, 'pnl_report'),
                  _buildQuickAction(context, 'Outstandings', Icons.warning_amber, 'outstanding'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            ResponsiveGridRow(
              children: [
                _buildSummaryCard(context, 'Total Revenue', '₹ 12,45,000', Icons.arrow_upward, Colors.green),
                _buildSummaryCard(context, 'Total Expenses', '₹ 4,30,000', Icons.arrow_downward, Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                _buildSummaryCard(context, 'Cash Balance', '₹ 45,000', Icons.account_balance_wallet, cs.primary),
                _buildSummaryCard(context, 'Bank Balance', '₹ 8,20,000', Icons.account_balance, cs.primary),
              ],
            ),
            const SizedBox(height: 24),

            Text('Recent Transactions', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildTransactionList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('add_expense'),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, String routeName) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        onPressed: () => context.goNamed(routeName),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String amount, IconData icon, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(amount, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final isCredit = index % 2 == 0;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isCredit ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? Colors.green : Colors.red,
                size: 16,
              ),
            ),
            title: Text(isCredit ? 'Sales Invoice #102$index' : 'Electricity Bill'),
            subtitle: Text('Today, 10:${index}0 AM'),
            trailing: Text(
              isCredit ? '+ ₹ 45,000' : '- ₹ 12,000',
              style: TextStyle(
                color: isCredit ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}

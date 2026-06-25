import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _expenses = [
    {'date': '2023-06-15', 'category': 'Electricity', 'amount': 12500.0, 'status': 'Approved', 'desc': 'Factory Bill - May'},
    {'date': '2023-06-14', 'category': 'Maintenance', 'amount': 4500.0, 'status': 'Pending', 'desc': 'Boiler Repair Parts'},
    {'date': '2023-06-12', 'category': 'Transport', 'amount': 2100.0, 'status': 'Rejected', 'desc': 'Local Delivery'},
    {'date': '2023-06-10', 'category': 'Office Supplies', 'amount': 850.0, 'status': 'Approved', 'desc': 'Printer Ink & Paper'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpenseList('Pending'),
          _buildExpenseList('Approved'),
          _buildExpenseList('Rejected'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('add_expense'),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildExpenseList(String statusFilter) {
    final filtered = _expenses.where((e) => e['status'] == statusFilter).toList();
    
    if (filtered.isEmpty) {
      return const Center(child: Text('No expenses found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final exp = filtered[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.receipt),
            ),
            title: Text(exp['category'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${exp['date']} \n${exp['desc']}'),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹ ${exp['amount'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                _buildStatusBadge(exp['status']),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Approved': color = Colors.green; break;
      case 'Pending': color = Colors.orange; break;
      case 'Rejected': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

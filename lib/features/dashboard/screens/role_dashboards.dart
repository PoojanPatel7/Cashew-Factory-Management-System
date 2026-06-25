import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manager Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Operations Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ResponsiveGridRow(
            children: [
              _buildStatCard(context, 'Production Today', '1,850 kg', Icons.precision_manufacturing, Colors.green),
              _buildStatCard(context, 'Pending Approvals', '8', Icons.pending_actions, Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Inventory Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text('Low Stock: W320 Grade'),
              subtitle: const Text('Only 50 kg remaining in finished goods.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey)),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class SupervisorDashboardPage extends StatelessWidget {
  const SupervisorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supervisor Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Floor Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ResponsiveGridRow(
            children: [
              _buildStatCard(context, 'Active Lots', '12', Icons.inventory, Colors.blue),
              _buildStatCard(context, 'Team Attendance', '45/50', Icons.people, Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.check), label: const Text('Log Stage Completion'))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.person_add), label: const Text('Mark Attendance'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey)),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class AccountantDashboardPage extends StatelessWidget {
  const AccountantDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accountant Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Finance Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ResponsiveGridRow(
            children: [
              _buildStatCard(context, 'Cash Balance', '₹ 1.2L', Icons.account_balance_wallet, Colors.green),
              _buildStatCard(context, 'Pending Payables', '₹ 4.5L', Icons.money_off, Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.receipt), label: const Text('Create Expense'))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.description), label: const Text('Generate Invoice'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey)),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class OperatorDashboardPage extends StatelessWidget {
  const OperatorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Operator Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('My Machine: Borma Dryer #1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            color: Colors.green.withValues(alpha: 0.1),
            child: const ListTile(
              leading: Icon(Icons.power, color: Colors.green),
              title: Text('Status: RUNNING', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              subtitle: Text('Temp: 85°C | Output Today: 450kg'),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 60,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Work Log (Lot-2026)'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.withValues(alpha: 0.1), foregroundColor: Colors.red),
              onPressed: () {},
              icon: const Icon(Icons.warning),
              label: const Text('Report Breakdown / Issue'),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerDashboardPage extends StatelessWidget {
  const WorkerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Worker Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Welcome, Rajesh Kumar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ResponsiveGridRow(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 32),
                      const SizedBox(height: 8),
                      const Text('Today\'s Status', style: TextStyle(color: Colors.grey)),
                      const Text('Checked In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.currency_rupee, color: Colors.blue, size: 32),
                      const SizedBox(height: 8),
                      const Text('Month Earnings', style: TextStyle(color: Colors.grey)),
                      const Text('₹ 8,450', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 60,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Check Out for the Day'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Latest Payslip (May 2026)'),
              trailing: const Icon(Icons.download),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

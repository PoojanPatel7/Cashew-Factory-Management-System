import 'package:flutter/material.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class MachineDetailPage extends StatelessWidget {
  const MachineDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Borma Dryer #1'),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(Icons.circle, color: Colors.green, size: 10),
                  SizedBox(width: 6),
                  Text('Running', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Live Status'),
              Tab(text: 'Today\'s Work'),
              Tab(text: 'History'),
              Tab(text: 'Maintenance'),
              Tab(text: 'Documents'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLiveStatusTab(context),
            _buildTodayWorkTab(context),
            _buildHistoryTab(context),
            _buildMaintenanceTab(context),
            _buildDocumentsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatusTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ResponsiveGridRow(
          children: [
            _buildGaugeCard(context, 'Temperature', '85°C', Colors.orange),
            _buildGaugeCard(context, 'Pressure', '1.2 atm', Colors.blue),
            _buildGaugeCard(context, 'Power', '12.4 kW', Colors.purple),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Operator Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                const ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Current Assigned: Ramesh Kumar'),
                  subtitle: Text('Shift: Morning (08:00 - 16:00)'),
                ),
                const Divider(),
                ResponsiveGridRow(
                  children: [
                    _buildInfoItem('Hours Today', '4.5 hrs'),
                    _buildInfoItem('Total Lifetime', '1,240 hrs'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayWorkTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Text('Total Output Today', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text('1,250 kg', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                Text('Efficiency: 92% (Target: 500kg/hr)', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Processed Lots', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        _buildLotCard('LOT-2026-015', '500 kg', '08:00 AM - 09:05 AM'),
        _buildLotCard('LOT-2026-016', '750 kg', '09:15 AM - 10:45 AM'),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Historical Analytics Chart Placeholder', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.orange.withValues(alpha: 0.1),
          child: const ListTile(
            leading: Icon(Icons.build, color: Colors.orange),
            title: Text('Next Scheduled Maintenance'),
            subtitle: Text('In 12 Days (2000 hours service)'),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Maintenance History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: const Text('Monthly Service'),
            subtitle: const Text('15-May-2026\nCost: ₹4,500 • Parts: Oil Filter'),
            isThreeLine: true,
            trailing: const Text('Completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
          title: const Text('User Manual - BD5000.pdf'),
          trailing: const Icon(Icons.download),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
          title: const Text('Warranty Certificate.pdf'),
          subtitle: const Text('Valid till 15-Jun-2028'),
          trailing: const Icon(Icons.download),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildGaugeCard(BuildContext context, String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(value: 0.8, color: color, strokeWidth: 8, backgroundColor: color.withValues(alpha: 0.2)),
                ),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildLotCard(String title, String qty, String time) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
        title: Text(title),
        subtitle: Text('Output: $qty\nTime: $time'),
        isThreeLine: true,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class MaintenanceLogEntryPage extends StatefulWidget {
  const MaintenanceLogEntryPage({super.key});

  @override
  State<MaintenanceLogEntryPage> createState() => _MaintenanceLogEntryPageState();
}

class _MaintenanceLogEntryPageState extends State<MaintenanceLogEntryPage> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Maintenance Log'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Machine: Steam Boiler'),
              Text('Type: Scheduled - Monthly Service'),
              Text('Cost: ₹8,500'),
              Text('Parts Used: Oil filter (₹1,200)'),
              Text('Downtime: 4 hours'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maintenance Logged. Spare Parts Deducted.')));
                context.pop();
              },
              child: const Text('Confirm ✓'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Maintenance')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: 'Steam Boiler',
              decoration: const InputDecoration(labelText: 'Machine'),
              items: ['Borma Dryer #1', 'Steam Boiler', 'Grader A']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                DropdownButtonFormField<String>(
                  value: 'Scheduled',
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['Scheduled', 'Breakdown']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {},
                ),
                TextFormField(decoration: const InputDecoration(labelText: 'Date', prefixIcon: Icon(Icons.calendar_today)), readOnly: true, initialValue: '25-Jun-2026'),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Description of Work Done'), maxLines: 2),
            const SizedBox(height: 24),
            const Text('Costs & Downtime', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                TextFormField(decoration: const InputDecoration(labelText: 'Labor Cost (₹)'), keyboardType: TextInputType.number),
                TextFormField(decoration: const InputDecoration(labelText: 'Downtime (Hours)'), keyboardType: TextInputType.number),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Technician Name')),
            const SizedBox(height: 24),
            const Text('Spare Parts Used', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Oil Filter (Model-X)'),
                subtitle: const Text('Qty: 1 • Unit Cost: ₹1,200'),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}),
              ),
            ),
            TextButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add Spare Part')),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt), label: const Text('Upload Photo Proof'))),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.save), label: const Text('Save Maintenance Log')),
            ),
          ],
        ),
      ),
    );
  }
}

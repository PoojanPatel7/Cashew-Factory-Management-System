import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class ScheduleMaintenancePage extends StatefulWidget {
  const ScheduleMaintenancePage({super.key});

  @override
  State<ScheduleMaintenancePage> createState() => _ScheduleMaintenancePageState();
}

class _ScheduleMaintenancePageState extends State<ScheduleMaintenancePage> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Schedule'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Machine: Peeling Machine #2'),
              Text('Trigger: By Hours (Every 500 hrs)'),
              Text('Assigned to: In-house Technician'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maintenance Task Scheduled')));
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
      appBar: AppBar(title: const Text('Schedule Maintenance')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: 'Peeling Machine #2',
              decoration: const InputDecoration(labelText: 'Select Machine'),
              items: ['Borma Dryer #1', 'Peeling Machine #2', 'Grader A']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: 'Preventive',
              decoration: const InputDecoration(labelText: 'Maintenance Type'),
              items: ['Preventive', 'Condition-based']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 24),
            const Text('Trigger Condition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: 'By Hours (e.g. Every 500 hrs)',
              decoration: const InputDecoration(labelText: 'Trigger Type'),
              items: ['By Hours (e.g. Every 500 hrs)', 'By Calendar (e.g. Every 30 days)', 'By Condition (Sensor)']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                TextFormField(decoration: const InputDecoration(labelText: 'Interval/Threshold Value'), keyboardType: TextInputType.number),
                TextFormField(decoration: const InputDecoration(labelText: 'Assigned Technician')),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description / Instructions'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.event), label: const Text('Save Schedule')),
            ),
          ],
        ),
      ),
    );
  }
}

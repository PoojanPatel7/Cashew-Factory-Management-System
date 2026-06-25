import 'package:flutter/material.dart';
import '../../../shared/widgets/responsive_grid_row.dart';

class PieceWorkEntryPage extends StatefulWidget {
  const PieceWorkEntryPage({super.key});

  @override
  State<PieceWorkEntryPage> createState() => _PieceWorkEntryPageState();
}

class _PieceWorkEntryPageState extends State<PieceWorkEntryPage> {
  final _formKey = GlobalKey<FormState>();
  String _employeeId = 'E001';
  String _taskType = 'Shelling';
  String _lot = 'LOT-2026-06-01';
  double _quantity = 0;
  double _rate = 15.0; // ₹15 per kg for shelling

  void _updateRate() {
    setState(() {
      if (_taskType == 'Shelling') _rate = 15.0;
      if (_taskType == 'Peeling') _rate = 12.0;
      if (_taskType == 'Grading') _rate = 10.0;
    });
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final earnings = _quantity * _rate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Piece-Work'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Employee: Ramesh Kumar ($_employeeId)'),
              Text('Task: $_taskType'),
              Text('Lot: $_lot'),
              const Divider(),
              Text('Quantity: $_quantity kg'),
              Text('Rate: ₹$_rate / kg'),
              const SizedBox(height: 8),
              Text(
                'Total Earnings: ₹${earnings.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Piece-Work Logged Successfully')),
                );
              },
              child: const Text('Confirm & Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Piece-Work')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<String>(
              value: _employeeId,
              decoration: const InputDecoration(
                labelText: 'Select Worker',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'E001', child: Text('Ramesh Kumar - Shelling')),
                DropdownMenuItem(value: 'E002', child: Text('Suresh Singh - Peeling')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _employeeId = val);
              },
            ),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                DropdownButtonFormField<String>(
                  value: _taskType,
                  decoration: const InputDecoration(
                    labelText: 'Task Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Shelling', 'Peeling', 'Grading'].map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _taskType = val;
                      _updateRate();
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _lot,
                  decoration: const InputDecoration(
                    labelText: 'Lot Number',
                    border: OutlineInputBorder(),
                  ),
                  items: ['LOT-2026-06-01', 'LOT-2026-06-02'].map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _lot = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveGridRow(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantity (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (double.tryParse(val) == null) return 'Invalid number';
                    return null;
                  },
                  onSaved: (val) => _quantity = double.parse(val!),
                  onChanged: (val) {
                    if (double.tryParse(val) != null) {
                      setState(() => _quantity = double.parse(val));
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Rate (₹)',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  initialValue: _rate.toString(),
                  key: ValueKey(_rate),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated Earnings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    '₹${(_quantity * _rate).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _handleSave,
              icon: const Icon(Icons.save),
              label: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Save Piece-Work Log', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

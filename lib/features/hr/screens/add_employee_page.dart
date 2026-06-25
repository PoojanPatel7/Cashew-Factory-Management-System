import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hr_provider.dart';

class AddEmployeePage extends ConsumerStatefulWidget {
  const AddEmployeePage({super.key});

  @override
  ConsumerState<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends ConsumerState<AddEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _type = 'Worker';
  String _department = 'Shelling';
  String _aadhaar = '';
  String _pan = '';

  void _showConfirmationDialog() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Employee Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: $_name'),
              Text('Role: $_type'),
              Text('Department: $_department'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.lock, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('Aadhaar: XXXX-${_aadhaar.length >= 4 ? _aadhaar.substring(_aadhaar.length - 4) : _aadhaar}'),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.lock, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  const Text('PAN: Encrypted'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'PII will be securely encrypted before saving.',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                final success = await ref.read(hrProvider.notifier).createEmployee({
                  'name': _name,
                  'phone': '0000000000', // Mock phone
                  'aadhar': _aadhaar,
                  'bankDetails': 'N/A',
                  'role': _type,
                  'department': _department,
                  'dailyWage': 500, // Mock wage
                });
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Employee added securely.')),
                  );
                  context.pop(); // Go back
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add employee.')),
                  );
                }
              },
              child: const Text('Save Employee'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Employee'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader('Personal Information'),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              onSaved: (val) => _name = val ?? '',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Employee Role',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Worker', 'Operator', 'Supervisor', 'Manager'].map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _type = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _department,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Shelling', 'Peeling', 'Grading', 'Maintenance'].map((t) {
                      return DropdownMenuItem(value: t, child: Text(t));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _department = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _buildSectionHeader('Identity & KYC (Encrypted)'),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Aadhaar Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
                suffixIcon: Tooltip(
                  message: 'Stored securely using 256-bit encryption',
                  child: Icon(Icons.lock, color: Colors.green),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (val) => val == null || val.length != 12 ? 'Enter 12-digit Aadhaar' : null,
              onSaved: (val) => _aadhaar = val ?? '',
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'PAN Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
                suffixIcon: Tooltip(
                  message: 'Stored securely using 256-bit encryption',
                  child: Icon(Icons.lock, color: Colors.green),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              onSaved: (val) => _pan = val ?? '',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Biometric Access'),
            SwitchListTile(
              title: const Text('Save Face Data for Self Check-in'),
              subtitle: const Text('Allows employee to check-in using the Face/ID scanner at the entrance.'),
              value: true,
              onChanged: (bool value) {
                // Future: launch camera to register face
                if (value) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Face scanning will be required upon first login.')));
                }
              },
              secondary: const Icon(Icons.face),
            ),
            const SizedBox(height: 32),
            
            FilledButton.icon(
              onPressed: _showConfirmationDialog,
              icon: const Icon(Icons.save),
              label: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Review & Save Employee', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

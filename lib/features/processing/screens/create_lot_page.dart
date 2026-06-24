import 'package:flutter/material.dart';
import '../../../shared/widgets/confirmation_dialog.dart';

class CreateLotPage extends StatefulWidget {
  const CreateLotPage({super.key});

  @override
  State<CreateLotPage> createState() => _CreateLotPageState();
}

class _CreateLotPageState extends State<CreateLotPage> {
  String? _selectedRcnBatch;
  final _qtyCtrl = TextEditingController();

  final List<Map<String, dynamic>> _rcnStock = [
    {'id': 'RCN-2026-001', 'supplier': 'Rajan Cashew Farm', 'available': 5000},
    {'id': 'RCN-2026-002', 'supplier': 'Global Nuts', 'available': 10000},
  ];

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_selectedRcnBatch == null || _qtyCtrl.text.isEmpty) return;

    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Start Processing Lot',
      icon: Icons.factory_outlined,
      fields: [
        ConfirmField(label: 'Source RCN Batch', value: _selectedRcnBatch!),
        ConfirmField(label: 'Processing Quantity', value: '${_qtyCtrl.text} kg', isBold: true),
        ConfirmField(label: 'Initial Stage', value: 'Boiling'),
      ],
      warnings: ['This will instantly deduct ${_qtyCtrl.text} kg from the Raw Material Inventory.'],
      confirmLabel: 'Start Lot',
      onConfirm: () {},
    );

    if (confirmed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lot LOT-2026-105 started in Boiling stage.')));
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start New Lot')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Raw Material (RCN)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Available RCN Batches',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  value: _selectedRcnBatch,
                  items: _rcnStock.map((b) => DropdownMenuItem<String>(
                    value: b['id'] as String,
                    child: Text('${b['id']} - ${b['supplier']} (${b['available']} kg available)'),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedRcnBatch = v),
                ),
                const SizedBox(height: 24),
                Text('Processing Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity to Process (kg) *',
                    prefixIcon: Icon(Icons.scale_rounded),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Processing Lot', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../providers/processing_provider.dart';
import '../../inventory/providers/inventory_provider.dart';

class CreateLotPage extends ConsumerStatefulWidget {
  const CreateLotPage({super.key});

  @override
  ConsumerState<CreateLotPage> createState() => _CreateLotPageState();
}

class _CreateLotPageState extends ConsumerState<CreateLotPage> {
  String? _selectedRcnBatch;
  final _qtyCtrl = TextEditingController();

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_selectedRcnBatch == null || _qtyCtrl.text.isEmpty) return;
    
    final rcnId = _selectedRcnBatch!;
    final qty = double.tryParse(_qtyCtrl.text) ?? 0;

    ConfirmationDialog.show(
      context,
      title: 'Start Processing Lot',
      icon: Icons.factory_outlined,
      fields: [
        ConfirmField(label: 'Source RCN Batch', value: rcnId),
        ConfirmField(label: 'Processing Quantity', value: '${_qtyCtrl.text} kg', isBold: true),
        ConfirmField(label: 'Initial Stage', value: 'Boiling'),
      ],
      warnings: ['This will instantly deduct ${_qtyCtrl.text} kg from the Raw Material Inventory.'],
      confirmLabel: 'Start Lot',
      onConfirm: () async {
        final success = await ref.read(processingProvider.notifier).createLot({
          'rcnId': rcnId,
          'initialWeight': qty,
        });

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lot started successfully.')));
            Navigator.pop(context); // close dialog
            if (Navigator.canPop(context)) Navigator.pop(context); // pop page
            
            // Refresh inventory because we deducted stock
            ref.read(inventoryProvider.notifier).fetchInventory();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to start lot.')));
            Navigator.pop(context); // close dialog
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryProvider);
    
    // For this example, assume inventory list has some RCN items. 
    // We just take items with 'category' == 'Raw Material' or similar if it exists.
    List<Map<String, dynamic>> rcnStock = [];
    if (inventoryState.value != null) {
      rcnStock = inventoryState.value!.where((item) => 
        (item['category'] == 'Raw Material' || item['sku']?.toString().startsWith('RCN') == true)
      ).toList();
    }

    // Fallback if empty (for UI testing purposes)
    if (rcnStock.isEmpty) {
      rcnStock = [
        {'id': 'RCN-2026-001', 'name': 'Rajan Cashew Farm', 'quantity': 5000},
        {'id': 'RCN-2026-002', 'name': 'Global Nuts', 'quantity': 10000},
      ];
    }

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
                  items: rcnStock.map((b) {
                    final id = b['id']?.toString() ?? 'Unknown ID';
                    final name = b['name']?.toString() ?? 'Unknown';
                    final qty = b['quantity']?.toString() ?? '0';
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text('$id - $name ($qty kg available)'),
                    );
                  }).toList(),
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

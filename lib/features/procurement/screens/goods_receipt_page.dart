import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../providers/po_provider.dart';

class GoodsReceiptPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? poData;
  const GoodsReceiptPage({super.key, this.poData});

  @override
  ConsumerState<GoodsReceiptPage> createState() => _GoodsReceiptPageState();
}

class _GoodsReceiptPageState extends ConsumerState<GoodsReceiptPage> {
  final _actualQtyCtrl = TextEditingController();
  final _actualMoistureCtrl = TextEditingController();
  final _qcNotesCtrl = TextEditingController();
  
  double get _variance {
    final actual = double.tryParse(_actualQtyCtrl.text) ?? 0;
    final expected = double.tryParse(widget.poData?['qty']?.toString().replaceAll(',', '') ?? '0') ?? 0;
    if (expected == 0) return 0;
    return ((actual - expected) / expected) * 100;
  }

  @override
  void dispose() {
    _actualQtyCtrl.dispose();
    _actualMoistureCtrl.dispose();
    _qcNotesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_actualQtyCtrl.text.isEmpty) return;
    
    final expectedQty = widget.poData?['qty'] ?? '0';
    final variancePercent = _variance.toStringAsFixed(2);
    
    Color varColor = Colors.green;
    if (_variance.abs() > 5) {
      varColor = Colors.red;
    } else if (_variance.abs() > 2) {
      varColor = Colors.orange;
    }

    ConfirmationDialog.show(
      context,
      title: 'Confirm Goods Receipt',
      icon: Icons.inventory_2_rounded,
      fields: [
        ConfirmField(label: 'PO Number', value: widget.poData?['id'] ?? ''),
        ConfirmField(label: 'Supplier', value: widget.poData?['supplier'] ?? ''),
        ConfirmField(label: 'Expected Qty', value: '$expectedQty kg'),
        ConfirmField(label: 'Actual Received', value: '${_actualQtyCtrl.text} kg', isBold: true),
        ConfirmField(label: 'Variance', value: '$_variance > 0 ? "+" : ""$variancePercent%', isBold: true, valueColor: varColor),
      ],
      confirmLabel: 'Receive to Inventory',
      onConfirm: () async {
        final poId = widget.poData?['id'] as String?;
        if (poId == null) return;

        // In a real scenario, you would have a specific inventory item ID for RCN.
        // For now, we mock an inventory item ID or fetch it if provided in poData.
        final inventoryItemId = widget.poData?['inventoryItemId'] ?? 'rcn-id';

        final success = await ref.read(poProvider.notifier).receiveGoods(poId, [
          {
            'id': inventoryItemId,
            'quantity': double.tryParse(_actualQtyCtrl.text) ?? 0.0,
          }
        ]);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inventory Updated Successfully')));
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Pop screen
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update inventory')));
            Navigator.pop(context); // Close dialog
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final po = widget.poData ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goods Receipt Note'),
        actions: [
          TextButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check),
            label: const Text('Confirm Receipt'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Expected from ${po['supplier']}', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                          const SizedBox(height: 4),
                          Text('${po['qty']} kg', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Icon(Icons.local_shipping_outlined, size: 48, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                Text('Actual Receipt & QC', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _actualQtyCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Actual Weight Received (kg) *',
                          prefixIcon: Icon(Icons.scale_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _actualMoistureCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tested Moisture %',
                          prefixIcon: Icon(Icons.water_drop_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (_actualQtyCtrl.text.isNotEmpty) _buildVarianceIndicator(theme),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _qcNotesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Gate QC Notes',
                    prefixIcon: Icon(Icons.notes),
                    hintText: 'e.g. High moisture detected, bag torn, etc.',
                  ),
                ),
                const SizedBox(height: 16),
                
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Capture Quality Photo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVarianceIndicator(ThemeData theme) {
    Color varColor = Colors.green;
    String statusText = 'Normal Variance (Within 2%)';
    IconData icon = Icons.check_circle_outline;

    if (_variance.abs() > 5) {
      varColor = Colors.red;
      statusText = 'High Variance - Requires Supervisor Approval';
      icon = Icons.error_outline;
    } else if (_variance.abs() > 2) {
      varColor = Colors.orange;
      statusText = 'Moderate Variance';
      icon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: varColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: varColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: varColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(statusText, style: TextStyle(color: varColor, fontWeight: FontWeight.bold)),
                Text('Variance: ${_variance > 0 ? "+" : ""}${_variance.toStringAsFixed(2)}%', style: TextStyle(color: varColor, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

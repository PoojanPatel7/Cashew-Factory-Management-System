import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../providers/processing_provider.dart';

class StageCompletionDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> lot;
  
  const StageCompletionDialog({super.key, required this.lot});

  @override
  ConsumerState<StageCompletionDialog> createState() => _StageCompletionDialogState();
}

class _StageCompletionDialogState extends ConsumerState<StageCompletionDialog> {
  final _outputCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _operator = 'Rajesh Kumar';
  String _machine = 'Line A';

  double get _inputQty => double.tryParse(widget.lot['qty']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0;
  
  double get _wastage {
    final output = double.tryParse(_outputCtrl.text) ?? 0;
    if (output == 0) return 0;
    return _inputQty - output;
  }
  
  double get _wastagePercent {
    if (_inputQty == 0) return 0;
    return (_wastage / _inputQty) * 100;
  }

  @override
  void dispose() {
    _outputCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_outputCtrl.text.isEmpty) return;
    
    final lotId = widget.lot['id']?.toString();
    final stageName = widget.lot['stage']?.toString();
    if (lotId == null || stageName == null) return;

    final outputWeight = double.tryParse(_outputCtrl.text) ?? 0;

    ConfirmationDialog.show(
      context,
      title: 'Complete Stage: $stageName',
      icon: Icons.check_circle_outline,
      fields: [
        ConfirmField(label: 'Lot', value: lotId),
        ConfirmField(label: 'Input', value: '${_inputQty} kg'),
        ConfirmField(label: 'Output', value: '$outputWeight kg', isBold: true, valueColor: Colors.green),
        ConfirmField(label: 'Wastage', value: '${_wastage} kg (${_wastagePercent.toStringAsFixed(1)}%)', isBold: true, valueColor: _wastagePercent > 10 ? Colors.red : Colors.orange),
        ConfirmField(label: 'Operator', value: _operator),
        ConfirmField(label: 'Machine', value: _machine),
      ],
      warnings: _wastagePercent > 10 ? ['High wastage detected. Supervisor approval will be required.'] : [],
      confirmLabel: 'Confirm Stage Completion',
      onConfirm: () async {
        final success = await ref.read(processingProvider.notifier).logStep(
          lotId,
          stageName,
          {
            'outputWeight': outputWeight,
            'wastageWeight': _wastage,
            'workerId': _operator,
            'machineId': _machine,
            'notes': _notesCtrl.text,
          }
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stage $stageName completed for $lotId')));
            Navigator.pop(context); // close dialog
            if (Navigator.canPop(context)) Navigator.pop(context); // pop modal
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to complete stage $stageName')));
            Navigator.pop(context); // close dialog
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Complete Stage: ${widget.lot['stage']}'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Input Quantity:', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    Text(widget.lot['qty'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _outputCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Output Quantity (kg) *',
                  prefixIcon: Icon(Icons.outbox_rounded),
                ),
              ),
              const SizedBox(height: 16),
              
              if (_outputCtrl.text.isNotEmpty) ...[
                Text('Calculated Wastage: ${_wastage} kg (${_wastagePercent.toStringAsFixed(1)}%)', 
                  style: TextStyle(
                    color: _wastagePercent > 10 ? Colors.red : Colors.orange,
                    fontWeight: FontWeight.bold,
                  )
                ),
                const SizedBox(height: 16),
              ],

              DropdownButtonFormField<String>(
                value: _operator,
                decoration: const InputDecoration(labelText: 'Operator', prefixIcon: Icon(Icons.person)),
                items: ['Rajesh Kumar', 'Anita S', 'Manoj D'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _operator = v!),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _machine,
                decoration: const InputDecoration(labelText: 'Machine', prefixIcon: Icon(Icons.precision_manufacturing_outlined)),
                items: ['Line A', 'Line B', 'Manual', 'Borma 1'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _machine = v!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Stage Notes / Temperature / Conditions',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Review & Complete')),
      ],
    );
  }
}

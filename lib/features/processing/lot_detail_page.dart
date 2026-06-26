import 'package:flutter/material.dart';
import '../../core/utils/date_parser.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/stock_providers.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../core/network/api_client.dart';

class LotDetailPage extends ConsumerWidget {
  final String lotId;
  const LotDetailPage({super.key, required this.lotId});

  static const _stages = ['CLEANING', 'BOILING', 'COOLING', 'SHELLING', 'DRYING', 'PEELING', 'GRADING', 'PACKING'];
  static const _stageLabels = {
    'CLEANING': 'Cleaning', 'BOILING': 'Boiling', 'COOLING': 'Cooling',
    'SHELLING': 'Shelling', 'DRYING': 'Drying (Borma)', 'PEELING': 'Peeling',
    'GRADING': 'Grading', 'PACKING': 'Packing', 'COMPLETED': 'Completed', 'PENDING': 'Pending',
  };
  static const _stageIcons = {
    'CLEANING': Icons.water_drop_rounded, 'BOILING': Icons.whatshot_rounded,
    'COOLING': Icons.ac_unit_rounded, 'SHELLING': Icons.broken_image_rounded,
    'DRYING': Icons.wb_sunny_rounded, 'PEELING': Icons.layers_rounded,
    'GRADING': Icons.sort_rounded, 'PACKING': Icons.inventory_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotAsync = ref.watch(lotDetailProvider(lotId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lot Details'),
        actions: [
          if (lotAsync.hasValue) ...[
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _showEditLotDialog(context, ref, lotAsync.value!),
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded),
              onPressed: () => _showTransferDialog(context, ref, lotAsync.value!),
              tooltip: 'Transfer to another factory',
            ),
          ]
        ],
      ),
      body: lotAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lot) {
          final name = lot['name'] ?? 'Unnamed';
          final category = lot['category'] ?? '';
          final initialW = (lot['initialWeight'] as num).toDouble();
          final currentW = (lot['currentWeight'] as num).toDouble();
          final stage = lot['currentStage'] ?? 'PENDING';
          final status = lot['status'] ?? 'PENDING';
          final steps = (lot['steps'] as List<dynamic>?) ?? [];
          final note = lot['note']?.toString();

          final currentIdx = _stages.indexOf(stage);
          final isCompleted = status == 'COMPLETED';
          final isProcessing = status == 'PROCESSING';
          
          final rsList = lot['sorting']?['rawStocks'] as List?;
          final rs = lot['sorting']?['rawStock'];
          final rsId = rsList != null && rsList.isNotEmpty ? rsList[0]['rawStockId'] : rs?['id'];
          
          String rsName = 'Unknown Batch';
          if (rsList != null && rsList.length > 1) {
            rsName = '${rsList.length} Batches';
          } else if (rsList != null && rsList.isNotEmpty) {
            final firstRs = rsList[0]['rawStock'];
            rsName = (firstRs != null && firstRs['name'] != null) ? firstRs['name'] : 'Unknown Batch';
          } else if (rs != null && rs['name'] != null) {
            rsName = rs['name'];
          }
          final rsDateStr = rsList != null && rsList.isNotEmpty ? (rsList[0]['date']?.toString() ?? '') : (rs?['date']?.toString() ?? '');
          final rsDate = formatFirebaseDate(rs?['date'] ?? (rsList != null && rsList.isNotEmpty ? rsList[0]['date'] : null), 'MMM dd, hh:mm a');
          
          final sortDateStr = lot['sorting']?['date']?.toString() ?? '';
          final sortDate = formatFirebaseDate(lot['sorting']?['date'], 'MMM dd, hh:mm a');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (rs != null || (rsList != null && rsList.isNotEmpty)) ...[
                      Text('Source Material', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        margin: EdgeInsets.zero,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            if (rsId != null) context.push('/raw-stock/$rsId');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.source_rounded, color: theme.colorScheme.primary, size: 32),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(rsName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('Received: $rsDate', style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
                                      Text('Sorted: $sortDate', style: TextStyle(color: theme.colorScheme.outline, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Lot info header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isCompleted
                              ? [Colors.green.shade700, Colors.green.shade500]
                              : [Colors.blue.shade700, Colors.blue.shade500],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _whiteInfo('Started', '${initialW.toStringAsFixed(1)} kg'),
                              const SizedBox(width: 32),
                              _whiteInfo('Current', '${currentW.toStringAsFixed(1)} kg'),
                              const SizedBox(width: 32),
                              _whiteInfo('Yield', '${(initialW > 0 ? (currentW / initialW * 100) : 0).toStringAsFixed(1)}%'),
                            ],
                          ),
                          if (note != null && note.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text('📝 $note', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ],
                      ),
                    ),

                    if (isProcessing) ...[
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            final confirm = await ConfirmationDialog.show(
                              context,
                              title: 'Revert to PENDING?',
                              icon: Icons.undo_rounded,
                              fields: [
                                ConfirmField(label: 'Target State', value: 'PENDING', isBold: true),
                              ],
                              warnings: ['This will delete all processing records and return the lot to the PENDING state. Are you sure?'],
                              confirmLabel: 'Revert',
                              confirmColor: Colors.orange,
                              onConfirm: () {},
                            );
                            if (confirm && context.mounted) {
                              final ok = await ref.read(lotsProvider.notifier).unstartLot(lotId);
                              if (ok && context.mounted) {
                                ref.invalidate(sortingProvider);
                                ref.invalidate(dashboardProvider);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lot reverted to PENDING')));
                                context.pop();
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to revert lot', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                              }
                            }
                          },
                          icon: const Icon(Icons.undo_rounded, color: Colors.orange),
                          label: const Text('Revert to Pending', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.orange.withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Visual pipeline
                    Text('Processing Pipeline', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: _stages.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final s = entry.value;
                            final isDone = isCompleted || idx < currentIdx;
                            final isCurrent = !isCompleted && idx == currentIdx;
                            final isPending = !isDone && !isCurrent;

                            // Find step data if exists
                            final step = steps.cast<Map<String, dynamic>>().where((st) => st['stageName'] == s).firstOrNull;

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    // Stage indicator
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(
                                        color: isDone ? Colors.green : (isCurrent ? Colors.blue : Colors.grey.shade200),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isDone ? Icons.check_rounded : (_stageIcons[s] ?? Icons.circle),
                                        color: isDone || isCurrent ? Colors.white : Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Stage info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _stageLabels[s] ?? s,
                                            style: TextStyle(
                                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                              fontSize: isCurrent ? 16 : 14,
                                              color: isPending ? Colors.grey : null,
                                            ),
                                          ),
                                          if (step != null) ...[
                                            Text(
                                              'In: ${(step['inputWeight'] as num).toStringAsFixed(1)} kg → Out: ${(step['outputWeight'] as num).toStringAsFixed(1)} kg',
                                              style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                                            ),
                                            Text(
                                              'Completed: ${formatFirebaseDate(step['completedAt'] ?? step['createdAt'] ?? step['updatedAt'], 'MMM dd, hh:mm a')}',
                                              style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                                            ),
                                            if (step['note'] != null && step['note'].toString().isNotEmpty)
                                              Text('📝 ${step['note']}', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
                                          ],
                                          if (isCurrent)
                                            Text('⏳ Current stage', style: TextStyle(fontSize: 12, color: Colors.blue)),
                                        ],
                                      ),
                                    ),
                                    // Wastage info
                                    if (step != null)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '-${(step['wastage'] as num).toStringAsFixed(1)} kg',
                                              style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            icon: const Icon(Icons.undo_rounded, color: Colors.orange, size: 20),
                                            tooltip: 'Revert to this stage',
                                            onPressed: () => _revertToStage(context, ref, s, lotId),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                            onPressed: () => _deleteStep(context, ref, step['id'], s, lotId),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                if (idx < _stages.length - 1)
                                  Container(
                                    margin: const EdgeInsets.only(left: 19),
                                    width: 2,
                                    height: 24,
                                    color: isDone ? Colors.green.shade300 : Colors.grey.shade300,
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Complete stage button
                    if (status == 'PENDING') ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            minimumSize: const Size(double.infinity, 56),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _showStartLotDialog(context, ref, lot),
                          icon: const Icon(Icons.play_arrow_rounded, size: 24),
                          label: const Text('Start Processing'),
                        ),
                      ),
                    ],

                    if (isProcessing) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _showCompleteStageSheet(context, ref, lot),
                          icon: const Icon(Icons.check_circle_rounded, size: 24),
                          label: Text('Complete ${_stageLabels[stage] ?? stage}'),
                        ),
                      ),
                    ],

                    if (isCompleted) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified_rounded, color: Colors.green, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Processing Complete!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                                  Text('Final packed weight: ${currentW.toStringAsFixed(1)} kg',
                                      style: TextStyle(color: Colors.green.shade700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange.shade700,
                            side: BorderSide(color: Colors.orange.shade300),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: () => _revertToStage(context, ref, 'PACKING', lotId),
                          icon: const Icon(Icons.undo_rounded),
                          label: const Text('Undo Completion & Edit Weights'),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _whiteInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white60, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showCompleteStageSheet(BuildContext context, WidgetRef ref, Map<String, dynamic> lot) {
    final stage = lot['currentStage'] ?? '';
    final currentW = (lot['currentWeight'] as num).toDouble();
    
    final factory = ref.read(currentFactoryProvider).value;
    final weighEvery = factory?['weighAtEveryStage'] ?? true;
    final isLastStage = stage == 'GRADING'; // next is packing
    final requireWeight = weighEvery || isLastStage;

    final outputCtrl = TextEditingController(text: requireWeight ? '' : currentW.toString());
    final noteCtrl = TextEditingController();
    String sortingMethod = 'MANUAL';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final output = double.tryParse(outputCtrl.text) ?? 0;
          final wastage = currentW - output;
          final wastagePercent = currentW > 0 ? (wastage / currentW * 100) : 0;

          return Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Text('Complete: ${_stageLabels[stage] ?? stage}',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Input: ${currentW.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 16, color: Colors.blue.shade700)),
                  const SizedBox(height: 20),
                  if (requireWeight) ...[
                    TextFormField(
                      controller: outputCtrl,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      onChanged: (_) => setSheetState(() {}),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        labelText: 'Output Weight (kg)',
                        hintText: 'How much came out?',
                        prefixIcon: Icon(Icons.scale_rounded),
                        suffixText: 'kg',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Output weight required';
                        final w = double.tryParse(v);
                        if (w == null) return 'Enter valid number';
                        if (w <= 0) return 'Must be > 0';
                        if (w > currentW + 0.01) return 'Cannot exceed input (${currentW.toStringAsFixed(1)} kg)';
                        return null;
                      },
                    ),
                    if (output > 0 && output <= currentW) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: wastagePercent > 10 ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Wastage: ${wastage.toStringAsFixed(1)} kg'),
                            Text('${wastagePercent.toStringAsFixed(1)}%',
                                style: TextStyle(fontWeight: FontWeight.bold, color: wastagePercent > 10 ? Colors.red : Colors.orange)),
                          ],
                        ),
                      ),
                    ],
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          const Expanded(child: Text('Weight tracking is bypassed for intermediate stages. Output weight will carry forward.')),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (stage == 'GRADING') ...[
                    DropdownButtonFormField<String>(
                      value: sortingMethod,
                      decoration: const InputDecoration(labelText: 'Sorting Method', prefixIcon: Icon(Icons.precision_manufacturing_rounded)),
                      items: const [
                        DropdownMenuItem(value: 'MANUAL', child: Text('Manual Sorting')),
                        DropdownMenuItem(value: 'MACHINE', child: Text('Machine Sorting')),
                      ],
                      onChanged: (v) => setSheetState(() => sortingMethod = v!),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      prefixIcon: Icon(Icons.note_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final o = double.parse(outputCtrl.text);
                      Navigator.pop(ctx);
                      final result = await ref.read(lotsProvider.notifier).completeStage(
                        lotId, o, noteCtrl.text.isEmpty ? null : noteCtrl.text,
                        sortingMethod: stage == 'GRADING' ? sortingMethod : null,
                      );
                      if (context.mounted) {
                        ref.invalidate(dashboardProvider);
                        ref.read(finishedProvider.notifier).fetch();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result != null ? '✅ Stage completed!' : '❌ Failed')),
                        );
                      }
                    },
                    child: const Text('Save & Complete Stage'),
                ),
              ],
            ),
           ),
          );
        },
      ),
    );
  }

  void _showStartLotDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> lot) {
    final weightCtrl = TextEditingController(text: lot['initialWeight'].toString());
    final noteCtrl = TextEditingController();
    
    final rsList = lot['sorting']?['rawStocks'] as List?;
    final rs = lot['sorting']?['rawStock'];
    
    String rsName = 'Unknown Batch';
    if (rsList != null && rsList.length > 1) {
      final names = rsList.map((r) => r['rawStock']?['name'] ?? 'Unknown').join(', ');
      rsName = '${rsList.length} Batches ($names)';
    } else if (rsList != null && rsList.isNotEmpty) {
      final firstRs = rsList[0]['rawStock'];
      rsName = (firstRs != null && firstRs['name'] != null) ? firstRs['name'] : 'Unknown Batch';
    } else if (rs != null && rs['name'] != null) {
      rsName = rs['name'];
    }
    
    // We only have one date to show if it's multiple, let's just use sorting date or hide date.
    final rsDateStr = lot['rawStock']?['date']?.toString() ?? '';
    final rsDate = formatFirebaseDate(lot['rawStock']?['date'], 'MMM dd, hh:mm a');
    final sortDateStr = lot['sorting']?['date']?.toString() ?? '';
    final sortDate = formatFirebaseDate(lot['sorting']?['date'], 'MMM dd, hh:mm a');

    showDialog(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Start Processing Lot'),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lot Name: ${lot['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Raw Stock: $rsName', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('Received: $rsDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const Divider(height: 16),
                        Text('Sorted On: $sortDate', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('You can start processing the full weight, or enter a custom partial weight to split this lot.'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Starting Weight (kg)',
                      prefixIcon: Icon(Icons.scale_rounded),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final w = double.tryParse(v);
                      if (w == null || w <= 0) return 'Invalid';
                      if (w > (lot['currentWeight'] as num).toDouble() + 0.01) return 'Max ${(lot['currentWeight'] as num).toStringAsFixed(1)}';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Confirmation Note (Optional)',
                      prefixIcon: Icon(Icons.note_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final w = double.parse(weightCtrl.text);
                
                Navigator.pop(ctx);
                final ok = await ref.read(lotsProvider.notifier).startLot(
                  lot['id'],
                  customWeight: w,
                  note: noteCtrl.text.trim(),
                );
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? '✅ Processing Started!' : '❌ Failed to start')),
                );
                ref.invalidate(lotDetailProvider(lot['id']));
                ref.invalidate(dashboardProvider);
              }
            },
            child: const Text('Confirm Start'),
          ),
          ],
        );
      },
    );
  }

  void _deleteStep(BuildContext context, WidgetRef ref, String stepId, String stageName, String lotId) async {
    final confirm = await ConfirmationDialog.showDelete(
      context,
      itemName: '${_stageLabels[stageName] ?? stageName} Step',
      details: 'This will revert the pipeline to this step, removing this record and all subsequent steps, while restoring the original weight.',
      onConfirm: () {},
    );

    if (confirm && context.mounted) {
      try {
        final ok = await ref.read(lotsProvider.notifier).revertToStage(lotId, stageName);
        if (context.mounted) {
          if (ok) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Step deleted and weight restored successfully')));
            ref.invalidate(lotDetailProvider(lotId));
            ref.invalidate(dashboardProvider);
            ref.read(finishedProvider.notifier).fetch();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete step'), backgroundColor: Colors.red));
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  void _revertToStage(BuildContext context, WidgetRef ref, String stageName, String lotId) async {
    final stageIdx = _stages.indexOf(stageName);
    final stagesAfter = _stages.sublist(stageIdx).map((s) => _stageLabels[s] ?? s).join(', ');
    
    final confirm = await ConfirmationDialog.show(
      context,
      title: 'Revert to ${_stageLabels[stageName]}?',
      icon: Icons.undo_rounded,
      fields: [
        ConfirmField(label: 'Target Stage', value: _stageLabels[stageName] ?? stageName, isBold: true),
        ConfirmField(label: 'Will Delete', value: stagesAfter),
      ],
      warnings: ['All processing records from ${_stageLabels[stageName]} onward will be permanently deleted'],
      confirmLabel: 'Revert',
      confirmColor: Colors.orange,
      onConfirm: () {},
    );

    if (confirm && context.mounted) {
      final ok = await ref.read(lotsProvider.notifier).revertToStage(lotId, stageName);
      if (context.mounted) {
        ref.invalidate(lotDetailProvider(lotId));
        ref.invalidate(dashboardProvider);
        ref.read(finishedProvider.notifier).fetch();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ok ? '✅ Reverted to ${_stageLabels[stageName]}' : '❌ Failed to revert')),
        );
      }
    }
  }

  void _showTransferDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> lot) async {
    try {
      final res = await FirebaseFirestore.instance.collection('factories').get();
      final factories = res.docs;
      final targetFactories = factories.where((f) => f.id != lot['factoryId']).toList();
      
      if (!context.mounted) return;
      if (targetFactories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No other factories available for transfer')));
        return;
      }
      
      showDialog(
        context: context,
        builder: (ctx) {
          String? selectedFactoryId = targetFactories.first.id;
          return StatefulBuilder(
            builder: (ctx, setDialogState) => AlertDialog(
              title: const Text('Transfer Lot'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transfer "${lot['name']}" to another factory.'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedFactoryId,
                    decoration: const InputDecoration(labelText: 'Target Factory'),
                    items: targetFactories.map((f) => DropdownMenuItem<String>(
                      value: f.id,
                      child: Text(f.data()['name']),
                    )).toList(),
                    onChanged: (v) => setDialogState(() => selectedFactoryId = v),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () async {
                    if (selectedFactoryId == null) return;
                    Navigator.pop(ctx);
                    final success = await ref.read(lotsProvider.notifier).transferLot(lot['id'], selectedFactoryId!);
                    if (context.mounted) {
                      if (success) {
                        ref.invalidate(dashboardProvider);
                        ref.invalidate(finishedProvider);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lot transferred successfully')));
                        context.pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to transfer lot')));
                      }
                    }
                  },
                  child: const Text('Transfer'),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load factories: $e')));
      }
    }
  }

  void _showEditLotDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> lot) {
    final nameCtrl = TextEditingController(text: lot['name']);
    final noteCtrl = TextEditingController(text: lot['note']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Lot'),
        content: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Lot Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(labelText: 'Note (Optional)'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final ok = await ref.read(lotsProvider.notifier).editLot(
                lot['id'],
                {
                  'name': nameCtrl.text,
                  'note': noteCtrl.text,
                  'currentWeight': lot['currentWeight'],
                  'status': lot['status'],
                }
              );
              if (ok) {
                ref.refresh(lotDetailProvider(lot['id']));
                if (ctx.mounted) Navigator.pop(ctx);
              } else {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Failed to update')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

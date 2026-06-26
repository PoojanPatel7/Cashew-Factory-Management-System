import 'package:flutter/material.dart';
import '../../core/utils/date_parser.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_client.dart';
import '../../providers/stock_providers.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

final rawStockDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final doc = await FirebaseFirestore.instance.collection('raw_stocks').doc(id).get();
  final data = doc.data() ?? {};
  data['id'] = doc.id;
  
  final sortingsState = ref.watch(sortingProvider);
  final allSortings = sortingsState.value ?? [];
  final relatedSortings = allSortings.where((s) {
    final rsList = s['rawStocks'] as List<dynamic>? ?? [];
    return rsList.any((rs) => rs['rawStockId'] == id);
  }).toList();
  
  data['sortings'] = relatedSortings;
  return data;
});

class RawStockDetailPage extends ConsumerWidget {
  final String id;
  const RawStockDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rawStockDetailProvider(id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Raw Stock Details'),
        actions: [
          if (state.hasValue)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => _showEditRawStockDialog(context, ref, state.value!),
            ),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => ref.refresh(rawStockDetailProvider(id))),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stock) {
          final sortings = (stock['sortings'] as List<dynamic>?) ?? [];
          final w = (stock['weight'] as num).toDouble();
          final u = (stock['usedWeight'] as num).toDouble();
          final remaining = w - u;
          final dateStr = stock['date'] ?? '';
          final date = formatFirebaseDate(stock['date'], 'MMM dd, yyyy - hh:mm a');
          final name = stock['name'] ?? 'Un-named Batch';
          final rawNote = stock['note']?.toString();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.orange.shade700, Colors.orange.shade500]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Raw Cashew Batch: $name', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('${w.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Received: $date\nAvailable: ${remaining.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    if (rawNote != null && rawNote.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('📝 Note: $rawNote', style: const TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic)),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sorting and Process Lifecycle
              if (sortings.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('This stock has not been sorted yet.', style: TextStyle(color: theme.colorScheme.outline)),
                  ),
                )
              else
                ...sortings.map((s) {
                  final sWeight = (s['totalWeight'] as num).toDouble();
                  final sDateStr = s['date'] ?? '';
                  final sDate = formatFirebaseDate(s['date'], 'MMM dd, yyyy - hh:mm a');
                  final sNote = s['note']?.toString();
                  final lots = (s['lots'] as List<dynamic>?) ?? [];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 24),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.category_rounded, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Sorting on $sDate', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Processed ${sWeight.toStringAsFixed(1)} kg into ${lots.length} lot(s)', style: TextStyle(color: theme.colorScheme.outline)),
                          if (sNote != null && sNote.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('📝 $sNote', style: TextStyle(color: theme.colorScheme.outline, fontStyle: FontStyle.italic, fontSize: 12)),
                          ],
                          const Divider(height: 32),
                          
                          ...lots.map((lot) {
                            final lWeight = (lot['currentWeight'] as num).toDouble();
                            final steps = (lot['steps'] as List<dynamic>?) ?? [];
                            final status = lot['status'];
                            final isFinished = lot['finishedStock'] != null;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${lot['name']} (${lot['category']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Chip(
                                        label: Text(isFinished ? 'PACKED' : status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                        backgroundColor: isFinished ? Colors.green.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.1),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Initial', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                            Text('${(lot['initialWeight'] as num).toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Final', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                            Text(isFinished ? '${(lot['finishedStock']['packedWeight'] as num).toStringAsFixed(1)} kg' : 'Pending', style: TextStyle(fontWeight: FontWeight.bold, color: isFinished ? Colors.green.shade700 : Colors.blue.shade700)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Yield', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                            Text(
                                              isFinished && (lot['initialWeight'] as num) > 0
                                                ? '${(((lot['finishedStock']['packedWeight'] as num) / (lot['initialWeight'] as num)) * 100).toStringAsFixed(1)}%' 
                                                : '--', 
                                              style: TextStyle(fontWeight: FontWeight.bold, color: isFinished ? Colors.green.shade700 : Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Pipeline Steps
                                  if (steps.isEmpty)
                                    Text('No processing started yet.', style: TextStyle(color: theme.colorScheme.outline, fontSize: 12))
                                  else
                                    Column(
                                      children: steps.map((step) {
                                        final stDate = formatFirebaseDate(step['completedAt'] ?? step['createdAt'] ?? step['updatedAt'], 'MMM dd, hh:mm a');
                                        final stNote = step['note']?.toString();
                                        
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(step['stageName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                                    Text(stDate, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                                    if (stNote != null && stNote.isNotEmpty) 
                                                      Text('📝 $stNote', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                                                  ]
                                                ),
                                              ),
                                              if ((step['wastage'] as num) > 0)
                                                Text('-${step['wastage']}kg waste', style: const TextStyle(color: Colors.red, fontSize: 12)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  void _showEditRawStockDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> stock) {
    final nameCtrl = TextEditingController(text: stock['name']);
    final weightCtrl = TextEditingController(text: stock['weight'].toString());
    final noteCtrl = TextEditingController(text: stock['note']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Raw Stock'),
        content: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Batch Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: weightCtrl,
                  decoration: const InputDecoration(labelText: 'Total Quantity (kg)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final w = double.tryParse(v);
                    if (w == null || w <= 0) return 'Invalid';
                    return null;
                  },
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
              final w = double.parse(weightCtrl.text);
              final ok = await ref.read(rawStockProvider.notifier).edit(
                stock['id'], w, nameCtrl.text, noteCtrl.text,
              );
              if (ok) {
                ref.refresh(rawStockDetailProvider(stock['id']));
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

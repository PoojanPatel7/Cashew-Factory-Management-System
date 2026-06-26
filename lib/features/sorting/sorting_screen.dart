import 'package:flutter/material.dart';
import '../../core/utils/date_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../providers/stock_providers.dart';
import '../../shared/widgets/logout_action.dart';
import '../../shared/widgets/confirmation_dialog.dart';
import '../../core/network/api_client.dart';
class SortingScreen extends ConsumerWidget {
  const SortingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sortingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text('✂️ Sorting', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: 0.5)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => ref.refresh(sortingProvider)),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sortings) {
          if (sortings.isEmpty) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.call_split_rounded, size: 64, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(height: 24),
                        Text('No sorting done yet', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Sort raw cashew into different lots', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                      ],
                    ),
                  ),
                ),
                _buildPageGuide(context),
              ],
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortings.length + 1,
                itemBuilder: (ctx, i) {
                  if (i == sortings.length) return _buildPageGuide(context);

                  final s = sortings[i] as Map<String, dynamic>;
                  final lots = (s['lots'] as List?) ?? [];
                  
                  
                  final sortDate = formatFirebaseDate(s['date'], 'MMM dd, hh:mm a');
                  
                  final rs = s['rawStock'];
                  final List? rsList = s['rawStocks'];
                  String rsName = 'Unknown Raw Stock';
                  String rsDate = '';
                  
                  if (rsList != null && rsList.isNotEmpty) {
                    if (rsList.length == 1) {
                      rsName = rsList[0]['rawStock']['name'] ?? 'Unknown Raw Stock';
                    } else {
                      rsName = '${rsList.length} Batches (${rsList.map((r) => r['rawStock']['name']).join(', ')})';
                    }
                  } else if (rs != null) {
                    rsName = rs['name'] ?? 'Unknown Raw Stock';
                    rsDate = formatFirebaseDate(rs['date'], 'MMM dd, yyyy');
                  }

                  final totalW = (s['totalWeight'] as num).toDouble();
                  final note = s['note']?.toString();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side Gradient Badge
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.indigo.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${totalW.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white, height: 1)),
                                const Text('kg', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Body
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(Icons.inventory_2_rounded, size: 16, color: theme.colorScheme.outline),
                                          const SizedBox(width: 6),
                                          Expanded(child: Text('From: $rsName ($rsDate)', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text('${lots.length} lots', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary, fontSize: 12)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 14, color: theme.colorScheme.outline),
                                    const SizedBox(width: 6),
                                    Text('Sorted: $sortDate', style: TextStyle(fontSize: 13, color: theme.colorScheme.outline)),
                                  ],
                                ),
                                if (note != null && note.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.notes_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(note, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic, fontSize: 13))),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: lots.map((lot) {
                                    final l = lot as Map<String, dynamic>;
                                    final status = l['status'] ?? 'PENDING';
                                    final stageColor = status == 'COMPLETED' ? Colors.green
                                        : status == 'PROCESSING' ? Colors.blue
                                        : theme.colorScheme.outline;
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                                        borderRadius: BorderRadius.circular(8),
                                        color: theme.colorScheme.surface,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () => context.push('/processing/${l['id']}'),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              child: Row(
                                                children: [
                                                  CircleAvatar(backgroundColor: stageColor, radius: 4),
                                                  const SizedBox(width: 8),
                                                  Text('${l['name']} • ${(l['initialWeight'] as num).toStringAsFixed(0)} kg', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.orange),
                                            onPressed: () => _showEditLotDialog(context, ref, l),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          // Right Action
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                            tooltip: 'Revert Sorting',
                            onPressed: () async {
                              final lotDetails = lots.map((l) => '• ${l['name']}: ${l['currentStage']} (${l['status']})').join('\n');
                              final confirm = await ConfirmationDialog.show(
                                context,
                                title: 'Revert Sorting & Delete Lots?',
                                icon: Icons.delete_outline,
                                fields: const [],
                                warnings: [
                                  'Current Lot Statuses:\n$lotDetails',
                                  'Are you absolutely sure you want to revert this sorting?',
                                  'All processing steps, finished stock, and lots will be PERMANENTLY deleted and weight returned to raw stock.'
                                ],
                                confirmLabel: 'Yes, Revert All',
                                confirmColor: Colors.red,
                                onConfirm: () {},
                              );
                              if (confirm && context.mounted) {
                                try {
                                  final docId = s['id'];
                                  final doc = await FirebaseFirestore.instance.collection('sortings').doc(docId).get();
                                  if (doc.exists) {
                                    final data = doc.data()!;
                                    final rawStocks = data['rawStocks'] ?? [];
                                    for (var rs in rawStocks) {
                                      try {
                                        await FirebaseFirestore.instance.collection('raw_stocks').doc(rs['rawStockId']).update({
                                          'usedWeight': FieldValue.increment(-rs['weight'])
                                        });
                                      } catch (e) {
                                        debugPrint('Could not update raw stock ${rs['rawStockId']}: $e');
                                      }
                                    }
                                    final lotsQuery = await FirebaseFirestore.instance.collection('lots').where('sortingId', isEqualTo: docId).get();
                                    for (var lotDoc in lotsQuery.docs) {
                                      await FirebaseFirestore.instance.collection('lots').doc(lotDoc.id).delete();
                                    }
                                    await FirebaseFirestore.instance.collection('sortings').doc(docId).delete();
                                  }
                                  ref.invalidate(sortingProvider);
                                  ref.invalidate(rawStockProvider);
                                  ref.invalidate(lotsProvider);
                                  ref.invalidate(dashboardProvider);
                                  ref.invalidate(globalDashboardProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sorting forcefully reverted successfully')));
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot revert: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/sorting/new'),
        icon: const Icon(Icons.call_split_rounded),
        label: const Text('Start Sorting'),
      ),
    );
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Lot Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Note (Optional)'),
                maxLines: 2,
              ),
            ],
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
                  'name': nameCtrl.text.trim(),
                  'note': noteCtrl.text.trim(),
                },
              );
              if (ok && ctx.mounted) {
                Navigator.pop(ctx);
                ref.invalidate(sortingProvider);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageGuide(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.secondaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: cs.primary),
              const SizedBox(width: 8),
              Text('How to use Sorting', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Tap the "Start Sorting" button below to convert Raw Stock into smaller Lots (e.g., W180, W210).\n'
            '• You will see the total weight sorted on the left badge, and the individual generated Lots on the bottom.\n'
            '• Tap on any Lot to jump straight to the Processing pipeline for that specific Lot.\n'
            '• Use the edit pencil to rename a Lot or add notes.',
            style: TextStyle(height: 1.5, color: cs.onSecondaryContainer.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

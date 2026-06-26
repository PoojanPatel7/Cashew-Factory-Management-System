import 'package:flutter/material.dart';
import '../../core/utils/date_parser.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/stock_providers.dart';
import '../../shared/widgets/logout_action.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  static const _stageLabels = {
    'PENDING': 'Pending',
    'CLEANING': 'Cleaning',
    'BOILING': 'Boiling',
    'COOLING': 'Cooling',
    'SHELLING': 'Shelling',
    'DRYING': 'Drying',
    'PEELING': 'Peeling',
    'GRADING': 'Grading',
    'PACKING': 'Packing',
    'COMPLETED': 'Completed',
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lotsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text('🏭 Processing', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: 0.5)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => ref.refresh(lotsProvider)),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Processing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allLots) {
          final pending = allLots.where((l) => l['status'] == 'PENDING').toList();
          final processing = allLots.where((l) => l['status'] == 'PROCESSING').toList();
          final completed = allLots.where((l) => l['status'] == 'COMPLETED').toList();

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _buildLotList(context, theme, pending, 'No pending lots', 'Start sorting to create lots', showStart: true),
              _buildLotList(context, theme, processing, 'No active processing', 'Start a pending lot to begin'),
              _buildLotList(context, theme, completed, 'No completed lots', 'Lots show here after all stages'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLotList(
    BuildContext context,
    ThemeData theme,
    List<Map<String, dynamic>> lots,
    String emptyTitle,
    String emptySubtitle, {
    bool showStart = false,
  }) {
    if (lots.isEmpty) {
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
                    child: Icon(Icons.precision_manufacturing_rounded, size: 64, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 24),
                  Text(emptyTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(emptySubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
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
          itemCount: lots.length + 1,
          itemBuilder: (ctx, i) {
            if (i == lots.length) return _buildPageGuide(context);

            final lot = lots[i];
            final stage = lot['currentStage'] ?? 'PENDING';
            final stageLabel = _stageLabels[stage] ?? stage;
            final weight = (lot['currentWeight'] as num).toDouble();
            final initialW = (lot['initialWeight'] as num).toDouble();
            final status = lot['status'] ?? 'PENDING';
            final sorting = lot['sorting'];
            String rawStockName = 'Unknown Raw Stock';
            if (sorting != null) {
              final List? rawStocksList = sorting['rawStocks'];
              if (rawStocksList != null && rawStocksList.isNotEmpty) {
                if (rawStocksList.length == 1) {
                  rawStockName = rawStocksList[0]['rawStock']?['name'] ?? 'Unknown Raw Stock';
                } else {
                  rawStockName = '${rawStocksList.length} Batches (${rawStocksList.map((r) => r['rawStock']?['name'] ?? 'Unknown').join(', ')})';
                }
              } else if (sorting['rawStock'] != null) {
                rawStockName = sorting['rawStock']['name'] ?? 'Unknown Raw Stock';
              }
            }
            final note = lot['note']?.toString();
            
            final dateStr = lot['updatedAt'] ?? lot['createdAt'] ?? '';
            final date = formatFirebaseDate(lot['updatedAt'] ?? lot['createdAt'], 'MMM dd, hh:mm a');

            Color stageColor;
            if (status == 'COMPLETED') {
              stageColor = Colors.green;
            } else if (status == 'PROCESSING') {
              stageColor = Colors.blue;
            } else {
              stageColor = Colors.grey;
            }

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
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.go('/processing/${lot['id']}'),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(lot['name'] ?? 'Unnamed Lot', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: stageColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(stageLabel, style: TextStyle(color: stageColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.inventory_2_rounded, size: 14, color: theme.colorScheme.outline),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text('From: $rawStockName', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                                if (date.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded, size: 14, color: theme.colorScheme.outline),
                                      const SizedBox(width: 6),
                                      Text(date, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                                    ],
                                  ),
                                ]
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.orange, size: 20),
                            onPressed: () => _showEditLotDialog(context, ref, lot),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (lot['category'] != null && lot['category'].toString().isNotEmpty)
                            _infoChip(context, Icons.category_rounded, lot['category']),
                          _infoChip(context, Icons.scale_rounded, '${weight.toStringAsFixed(1)} kg'),
                          if (status == 'PROCESSING')
                            _infoChip(context, Icons.trending_down_rounded, 'Started: ${initialW.toStringAsFixed(0)} kg'),
                        ],
                      ),
                      if (note != null && note.isNotEmpty) ...[
                        const SizedBox(height: 16),
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
                      if (status == 'PROCESSING') ...[
                        const SizedBox(height: 20),
                        _buildMiniPipeline(stage),
                      ],
                      if (showStart && status == 'PENDING') ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _showStartLotDialog(context, ref, lot),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Start Processing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.outline),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMiniPipeline(String currentStage) {
    const stages = ['CLEANING', 'BOILING', 'COOLING', 'SHELLING', 'DRYING', 'PEELING', 'GRADING', 'PACKING'];
    final currentIdx = stages.indexOf(currentStage);

    return Row(
      children: List.generate(stages.length, (i) {
        final isDone = i < currentIdx;
        final isCurrent = i == currentIdx;
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: isDone ? Colors.green : (isCurrent ? Colors.blue : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  void _showStartLotDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> lot) {
    final maxWeight = (lot['currentWeight'] as num).toDouble();
    final weightCtrl = TextEditingController(text: maxWeight.toString());
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    final date = formatFirebaseDate(lot['updatedAt'] ?? lot['createdAt'], 'MMM dd, hh:mm a');
    final sorting = lot['sorting'];
    String rsName = 'Unknown';
    if (sorting != null) {
      final rsList = sorting['rawStocks'] as List?;
      if (rsList != null && rsList.isNotEmpty) {
        rsName = rsList[0]['rawStock']?['name'] ?? 'Unknown';
      } else if (sorting['rawStock'] != null) {
        rsName = sorting['rawStock']['name'] ?? 'Unknown';
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Processing Lot'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lot: ${lot['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('From: $rsName'),
                Text('Total: ${maxWeight.toStringAsFixed(1)} kg'),
                if (date.isNotEmpty) Text('Date: $date'),
                const Divider(height: 24),
                const Text('Enter full weight or partial weight to split.'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Starting Weight (kg)',
                    prefixIcon: Icon(Icons.scale_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Weight required';
                    final w = double.tryParse(v);
                    if (w == null) return 'Enter valid number';
                    if (w <= 0) return 'Must be > 0';
                    if (w > maxWeight + 0.01) return 'Max ${maxWeight.toStringAsFixed(1)} kg';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Note (Optional)',
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
                ref.invalidate(dashboardProvider);
              }
            },
            child: const Text('Confirm Start'),
          ),
        ],
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
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Lot Name'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
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
              final ok = await ref.read(lotsProvider.notifier).editLot(
                lot['id'],
                {'name': nameCtrl.text, 'note': noteCtrl.text},
              );
              if (ok) {
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
              Text('How to use Processing', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• The Processing page tracks individual Lots as they move through the factory stages.\n'
            '• Pending Tab: Lots created in Sorting but not yet started. Tap "Start Processing" to begin.\n'
            '• Processing Tab: Lots currently active. Tap a card to enter its pipeline and update stage weights.\n'
            '• Completed Tab: Finished Stock ready for dispatch.\n'
            '• You can edit names and notes anytime using the orange pencil icon.',
            style: TextStyle(height: 1.5, color: cs.onSecondaryContainer.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

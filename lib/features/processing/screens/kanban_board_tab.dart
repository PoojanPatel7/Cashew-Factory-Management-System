import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../widgets/stage_completion_dialog.dart';
import '../providers/processing_provider.dart';

class KanbanBoardTab extends ConsumerStatefulWidget {
  const KanbanBoardTab({super.key});

  @override
  ConsumerState<KanbanBoardTab> createState() => _KanbanBoardTabState();
}

class _KanbanBoardTabState extends ConsumerState<KanbanBoardTab> {
  final List<String> stages = ['Boiling', 'Cooling', 'Shelling', 'Borma', 'Peeling', 'Grading', 'Packing'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lotState = ref.watch(processingProvider);

    return Scaffold(
      body: lotState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allLots) {
          final activeLots = allLots.where((l) => l['status'] == 'Active').toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: stages.map((stage) {
                final stageLots = activeLots.where((l) => l['stage'] == stage).toList();
                return _buildKanbanColumn(theme, stage, stageLots);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKanbanColumn(ThemeData theme, String title, List<Map<String, dynamic>> stageLots) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${stageLots.length}', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: stageLots.length,
              itemBuilder: (ctx, i) => _buildLotCard(theme, stageLots[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLotCard(ThemeData theme, Map<String, dynamic> lot) {
    final lotId = lot['id']?.toString() ?? 'N/A';
    final qty = lot['qty']?.toString() ?? '0';
    final timeStr = '2h 15m'; // Mock time, real time needs elapsed calculation based on lot['updatedAt'] or 'createdAt'

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lotId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                StatusBadge.running(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.scale_rounded, size: 16, color: theme.textTheme.bodySmall?.color),
                const SizedBox(width: 8),
                Text('$qty kg', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 16, color: theme.textTheme.bodySmall?.color),
                const SizedBox(width: 8),
                Text('Elapsed: $timeStr', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              ],
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => StageCompletionDialog(lot: lot),
                  );
                },
                child: const Text('Complete Stage'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

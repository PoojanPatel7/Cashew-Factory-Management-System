import 'package:flutter/material.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../widgets/stage_completion_dialog.dart';

class KanbanBoardTab extends StatefulWidget {
  const KanbanBoardTab({super.key});

  @override
  State<KanbanBoardTab> createState() => _KanbanBoardTabState();
}

class _KanbanBoardTabState extends State<KanbanBoardTab> {
  final List<String> stages = ['Boiling', 'Cooling', 'Shelling', 'Borma', 'Peeling', 'Grading', 'Packing'];
  
  // Mock lot data
  final List<Map<String, dynamic>> lots = [
    {'id': 'LOT-101', 'stage': 'Boiling', 'qty': '1000 kg', 'time': '2h 15m', 'status': 'Running'},
    {'id': 'LOT-102', 'stage': 'Cooling', 'qty': '850 kg', 'time': '12h 0m', 'status': 'Idle'},
    {'id': 'LOT-103', 'stage': 'Shelling', 'qty': '500 kg', 'time': '1h 30m', 'status': 'Running'},
    {'id': 'LOT-104', 'stage': 'Borma', 'qty': '1200 kg', 'time': '4h 45m', 'status': 'Running'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: stages.map((stage) {
            final stageLots = lots.where((l) => l['stage'] == stage).toList();
            return _buildKanbanColumn(theme, stage, stageLots);
          }).toList(),
        ),
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
                Text(lot['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                lot['status'] == 'Running' ? StatusBadge.running() : StatusBadge.idle(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.scale_rounded, size: 16, color: theme.textTheme.bodySmall?.color),
                const SizedBox(width: 8),
                Text(lot['qty'], style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 16, color: theme.textTheme.bodySmall?.color),
                const SizedBox(width: 8),
                Text('Elapsed: ${lot['time']}', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
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

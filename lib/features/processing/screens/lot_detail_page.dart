import 'package:flutter/material.dart';
import '../../../shared/widgets/common_widgets.dart';

class LotDetailPage extends StatelessWidget {
  final Map<String, dynamic>? lotData;

  const LotDetailPage({super.key, this.lotData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;
    
    final lot = lotData ?? {
      'id': 'LOT-101',
      'date': '24-Jun-2026',
      'rcn': 'RCN-2026-001',
      'qty': '1000 kg',
      'stage': 'Boiling',
      'status': 'Active',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Lot Details: ${lot['id']}'),
        actions: [
          StatusBadge(
            label: lot['status'],
            color: lot['status'] == 'Active' ? Colors.blue : Colors.green,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildMainContent(theme, lot)),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildSideContent(theme)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainContent(theme, lot),
                  const SizedBox(height: 24),
                  _buildSideContent(theme),
                ],
              ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, Map<String, dynamic> lot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLotInfo(theme, lot),
        const SizedBox(height: 32),
        Text('Processing Pipeline', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildVisualPipeline(theme),
        const SizedBox(height: 32),
        Text('Stage History', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildStageHistory(theme),
      ],
    );
  }

  Widget _buildSideContent(ThemeData theme) {
    return Column(
      children: [
        _buildYieldCalculator(theme),
        const SizedBox(height: 24),
        _buildActionLog(theme),
      ],
    );
  }

  Widget _buildLotInfo(ThemeData theme, Map<String, dynamic> lot) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Wrap(
        spacing: 48,
        runSpacing: 24,
        children: [
          _infoItem(theme, 'Source RCN', lot['rcn'], Icons.inventory_2_outlined),
          _infoItem(theme, 'Date Started', lot['date'], Icons.calendar_today_outlined),
          _infoItem(theme, 'Initial Quantity', lot['qty'], Icons.scale_rounded),
          _infoItem(theme, 'Current Stage', lot['stage'], Icons.label_important_outline),
        ],
      ),
    );
  }

  Widget _infoItem(ThemeData theme, String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: theme.textTheme.bodySmall?.color)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildVisualPipeline(ThemeData theme) {
    final stages = ['Boiling', 'Cooling', 'Shelling', 'Borma', 'Peeling', 'Grading', 'Packing'];
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(stages.length, (index) {
            final isCompleted = index < 2;
            final isCurrent = index == 2;
            return Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : (isCurrent ? Colors.blue : theme.colorScheme.surfaceContainerHighest),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? Colors.green : (isCurrent ? Colors.blue : theme.colorScheme.outline.withValues(alpha: 0.3)),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : (isCurrent ? Icons.play_arrow : Icons.hourglass_empty),
                        color: isCompleted || isCurrent ? Colors.white : theme.colorScheme.outline,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(stages[index], style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? Colors.blue : (isCompleted ? Colors.green : theme.textTheme.bodySmall?.color),
                    )),
                  ],
                ),
                if (index < stages.length - 1)
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    color: isCompleted ? Colors.green : theme.colorScheme.surfaceContainerHighest,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStageHistory(ThemeData theme) {
    final history = [
      {'stage': 'Boiling', 'in': '1000 kg', 'out': '1000 kg', 'operator': 'Manoj D', 'time': '2h 15m'},
      {'stage': 'Cooling', 'in': '1000 kg', 'out': '980 kg', 'operator': 'Anita S', 'time': '12h 0m'},
    ];

    return Column(
      children: history.map((h) => ExpansionTile(
        title: Text(h['stage']!),
        subtitle: Text('Operator: ${h['operator']} | Time: ${h['time']}'),
        leading: const Icon(Icons.check_circle, color: Colors.green),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [const Text('Input'), Text(h['in']!, style: const TextStyle(fontWeight: FontWeight.bold))]),
                const Icon(Icons.arrow_forward),
                Column(children: [const Text('Output'), Text(h['out']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]),
              ],
            ),
          )
        ],
      )).toList(),
    );
  }

  Widget _buildYieldCalculator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yield Calculator', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Outturn %'),
              Text('24.8%', style: theme.textTheme.titleLarge?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Industry Benchmark: 24.5%', style: TextStyle(color: Colors.orange)),
          const SizedBox(height: 24),
          const LinearProgressIndicator(value: 0.8, color: Colors.green, backgroundColor: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildActionLog(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity Log', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(height: 32),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.check, color: Colors.green),
            title: Text('Cooling Stage Completed'),
            subtitle: Text('24-Jun-2026 14:30 | Anita S'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.check, color: Colors.green),
            title: Text('Boiling Stage Completed'),
            subtitle: Text('24-Jun-2026 02:30 | Manoj D'),
          ),
        ],
      ),
    );
  }
}

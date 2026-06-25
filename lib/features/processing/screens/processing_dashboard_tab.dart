import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../providers/processing_provider.dart';

class ProcessingDashboardTab extends ConsumerWidget {
  const ProcessingDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    final lotState = ref.watch(processingProvider);
    final lots = lotState.value ?? [];

    final activeLots = lots.where((l) => l['status'] == 'Active').length;
    
    // Compute pipeline counts
    final pipelineCounts = <String, int>{
      'Boiling': 0, 'Cooling': 0, 'Shelling': 0, 
      'Borma': 0, 'Peeling': 0, 'Grading': 0,
    };
    
    for (var lot in lots) {
      if (lot['status'] == 'Active') {
        final stage = lot['stage']?.toString() ?? '';
        if (pipelineCounts.containsKey(stage)) {
          pipelineCounts[stage] = pipelineCounts[stage]! + 1;
        }
      }
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/processing/create_lot'),
        icon: const Icon(Icons.add),
        label: const Text('Start New Lot'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Today\'s Performance', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(processingProvider.notifier).fetchLots(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard(theme, 'Active Lots', activeLots.toString(), Icons.view_in_ar, Colors.blue, isWide, context),
                _buildStatCard(theme, 'Output Today', '1,250 kg', Icons.scale, Colors.green, isWide, context),
                _buildStatCard(theme, 'Overall Yield', '24.5%', Icons.pie_chart, Colors.orange, isWide, context),
                _buildStatCard(theme, 'Pending Approvals', '3', Icons.pending_actions, Colors.red, isWide, context),
              ],
            ),
            
            const SizedBox(height: 48),
            Text('Pipeline Overview (Lots per Stage)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPipelineStage(theme, 'Boiling', pipelineCounts['Boiling']!),
                  _pipelineConnector(theme),
                  _buildPipelineStage(theme, 'Cooling', pipelineCounts['Cooling']!),
                  _pipelineConnector(theme),
                  _buildPipelineStage(theme, 'Shelling', pipelineCounts['Shelling']!),
                  _pipelineConnector(theme),
                  _buildPipelineStage(theme, 'Borma', pipelineCounts['Borma']!),
                  _pipelineConnector(theme),
                  _buildPipelineStage(theme, 'Peeling', pipelineCounts['Peeling']!),
                  _pipelineConnector(theme),
                  _buildPipelineStage(theme, 'Grading', pipelineCounts['Grading']!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color, bool isWide, BuildContext context) {
    return Container(
      width: isWide ? 200 : (MediaQuery.of(context).size.width / 2) - 32,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: theme.textTheme.bodySmall?.color)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
        ],
      ),
    );
  }

  Widget _buildPipelineStage(ThemeData theme, String stage, int count) {
    final isActive = count > 0;
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.5) : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(stage, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: isActive ? theme.colorScheme.onPrimary : theme.textTheme.bodySmall?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pipelineConnector(ThemeData theme) {
    return Container(
      width: 40,
      height: 2,
      color: theme.colorScheme.outline.withValues(alpha: 0.3),
    );
  }
}

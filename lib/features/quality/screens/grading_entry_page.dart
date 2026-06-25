import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../providers/quality_provider.dart';

class GradingEntryPage extends ConsumerStatefulWidget {
  const GradingEntryPage({super.key});

  @override
  ConsumerState<GradingEntryPage> createState() => _GradingEntryPageState();
}

class _GradingEntryPageState extends ConsumerState<GradingEntryPage> {
  final Map<String, TextEditingController> _controllers = {
    'W180': TextEditingController(),
    'W210': TextEditingController(),
    'W240': TextEditingController(),
    'W320': TextEditingController(),
    'SW': TextEditingController(),
    'Splits': TextEditingController(),
    'Pieces': TextEditingController(),
  };

  final Map<String, Color> _colors = {
    'W180': Colors.amber,
    'W210': Colors.orange,
    'W240': Colors.deepOrange,
    'W320': Colors.redAccent,
    'SW': Colors.purple,
    'Splits': Colors.grey,
    'Pieces': Colors.blueGrey,
  };

  double _totalInput = 1200.0; // Mock total input weight of the lot
  String _lotId = 'LOT-2026-100'; // Mock lot ID

  @override
  void initState() {
    super.initState();
    for (var ctrl in _controllers.values) {
      ctrl.addListener(_updateChart);
    }
  }

  @override
  void dispose() {
    for (var ctrl in _controllers.values) {
      ctrl.removeListener(_updateChart);
      ctrl.dispose();
    }
    super.dispose();
  }

  void _updateChart() {
    setState(() {});
  }

  Map<String, double> _getValues() {
    Map<String, double> vals = {};
    for (var entry in _controllers.entries) {
      vals[entry.key] = double.tryParse(entry.value.text) ?? 0.0;
    }
    return vals;
  }

  double get _totalEntered {
    return _getValues().values.fold(0.0, (a, b) => a + b);
  }

  void _submit() async {
    final vals = _getValues();
    if (_totalEntered <= 0) return;

    List<ConfirmField> fields = [
      ConfirmField(label: 'Total Output', value: '${_totalEntered} kg', isBold: true),
      ConfirmField(label: 'Yield', value: '${((_totalEntered / _totalInput) * 100).toStringAsFixed(1)}%'),
    ];

    vals.forEach((grade, weight) {
      if (weight > 0) {
        fields.add(ConfirmField(label: grade, value: '$weight kg'));
      }
    });

    ConfirmationDialog.show(
      context,
      title: 'Confirm Grading Entry',
      icon: Icons.done_all_rounded,
      fields: fields,
      warnings: ['This will finalize $_lotId and add the graded kernels to Finished Goods Stock.'],
      confirmLabel: 'Confirm & Finalize',
      onConfirm: () async {
        final success = await ref.read(qualityProvider.notifier).submitGrade(
          _lotId,
          vals,
          'Final grading complete. Checked by QC.'
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grading complete. Stock updated!')));
            Navigator.pop(context); // close dialog
            if (Navigator.canPop(context)) Navigator.pop(context); // pop page
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit grading.')));
            Navigator.pop(context); // close dialog
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;
    final vals = _getValues();

    return Scaffold(
      appBar: AppBar(title: const Text('Lot Grading Entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: isWide 
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildForm(theme)),
                  const SizedBox(width: 32),
                  Expanded(flex: 2, child: _buildPreview(theme, vals)),
                ],
              )
            : Column(
                children: [
                  _buildForm(theme),
                  const SizedBox(height: 32),
                  _buildPreview(theme, vals),
                ],
              ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LOT-2026-100 | Input: $_totalInput kg', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _controllers.entries.map((e) => _buildGradeInput(e.key, e.value)).toList(),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Finalize Grading'),
          ),
        ),
      ],
    );
  }

  Widget _buildGradeInput(String label, TextEditingController ctrl) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return SizedBox(
      width: isWide ? 200 : double.infinity,
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '$label (kg)',
          prefixIcon: const Icon(Icons.scale_rounded, size: 20),
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme, Map<String, double> vals) {
    final hasData = _totalEntered > 0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('Grading Distribution', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: hasData
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: vals.entries.where((e) => e.value > 0).map((e) {
                        final percentage = (e.value / _totalEntered) * 100;
                        return PieChartSectionData(
                          value: e.value,
                          color: _colors[e.key],
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  )
                : const Center(child: Text('Enter weights to see distribution chart')),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Graded:'),
              Text('$_totalEntered kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recovery Yield:'),
              Text('${((_totalEntered / _totalInput) * 100).toStringAsFixed(1)}%', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

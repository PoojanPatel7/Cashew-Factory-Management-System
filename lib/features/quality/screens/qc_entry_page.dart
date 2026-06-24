import 'package:flutter/material.dart';
import '../../../shared/widgets/confirmation_dialog.dart';

class QCEntryPage extends StatefulWidget {
  const QCEntryPage({super.key});

  @override
  State<QCEntryPage> createState() => _QCEntryPageState();
}

class _QCEntryPageState extends State<QCEntryPage> {
  double _moisture = 4.5;
  double _broken = 2.0;
  String _colorGrade = 'White';
  bool _foreignMaterial = false;
  bool _aflatoxinPassed = true;
  bool _metalDetected = false;

  bool get _isPass => _moisture <= 5.0 && _broken <= 5.0 && !_foreignMaterial && _aflatoxinPassed && !_metalDetected;

  void _submit() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Sign Off Quality Check',
      icon: Icons.assignment_turned_in_rounded,
      fields: [
        ConfirmField(label: 'Lot', value: 'LOT-2026-105'),
        ConfirmField(label: 'Overall Status', value: _isPass ? 'PASS' : 'FAIL', isBold: true, valueColor: _isPass ? Colors.green : Colors.red),
        ConfirmField(label: 'Moisture', value: '${_moisture.toStringAsFixed(1)}%'),
        ConfirmField(label: 'Aflatoxin Check', value: _aflatoxinPassed ? 'Cleared' : 'Failed'),
      ],
      warnings: _isPass ? [] : ['This lot has failed QC. It will be marked for review.'],
      confirmLabel: 'Sign Off',
      onConfirm: () {},
    );

    if (confirmed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quality Check recorded successfully.')));
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(title: const Text('New Quality Check')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: isWide 
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildForm(theme)),
                  const SizedBox(width: 32),
                  Expanded(flex: 1, child: _buildSummary(theme)),
                ],
              )
            : Column(
                children: [
                  _buildForm(theme),
                  const SizedBox(height: 32),
                  _buildSummary(theme),
                ],
              ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Physical Parameters', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildSlider(theme, 'Moisture Content (%)', _moisture, 0, 10, (v) => setState(() => _moisture = v), 5.0),
        _buildSlider(theme, 'Broken Ratio (%)', _broken, 0, 15, (v) => setState(() => _broken = v), 5.0),
        const SizedBox(height: 24),
        Text('Color Grade', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: ['White', 'Scorched', 'Dessert'].map((c) => ChoiceChip(
            label: Text(c),
            selected: _colorGrade == c,
            onSelected: (sel) { if (sel) setState(() => _colorGrade = c); },
          )).toList(),
        ),
        const SizedBox(height: 32),
        Text('Safety Checks', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Foreign Material Found?'),
          subtitle: const Text('Check for stones, shell pieces, etc.'),
          value: _foreignMaterial,
          onChanged: (v) => setState(() => _foreignMaterial = v),
          activeColor: Colors.red,
        ),
        SwitchListTile(
          title: const Text('Metal Detection Failed?'),
          value: _metalDetected,
          onChanged: (v) => setState(() => _metalDetected = v),
          activeColor: Colors.red,
        ),
        SwitchListTile(
          title: const Text('Aflatoxin Test Cleared?'),
          value: _aflatoxinPassed,
          onChanged: (v) => setState(() => _aflatoxinPassed = v),
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildSlider(ThemeData theme, String label, double val, double min, double max, ValueChanged<double> onChanged, double threshold) {
    final isDanger = val > threshold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${val.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, color: isDanger ? Colors.red : Colors.green)),
          ],
        ),
        Slider(
          value: val,
          min: min,
          max: max,
          divisions: ((max - min) * 10).toInt(),
          activeColor: isDanger ? Colors.red : theme.colorScheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isPass ? Colors.green.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            _isPass ? Icons.verified_rounded : Icons.warning_rounded,
            size: 64,
            color: _isPass ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _isPass ? 'QC PASSED' : 'QC FAILED',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: _isPass ? Colors.green : Colors.red),
          ),
          const SizedBox(height: 8),
          Text(
            _isPass ? 'All parameters within acceptable limits.' : 'One or more parameters failed safety limits.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.draw_rounded),
            label: const Text('Sign Off & Complete'),
            style: FilledButton.styleFrom(
              backgroundColor: _isPass ? Colors.green : Colors.red,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}

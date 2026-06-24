import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QCChecklistTab extends StatelessWidget {
  const QCChecklistTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final qcs = [
      {'lot': 'LOT-2026-101', 'inspector': 'Aman S.', 'status': 'Pass', 'time': '10:30 AM'},
      {'lot': 'LOT-2026-098', 'inspector': 'Priya R.', 'status': 'Pass', 'time': '09:15 AM'},
      {'lot': 'LOT-2026-102', 'inspector': 'Aman S.', 'status': 'Fail', 'time': 'Yesterday'},
    ];

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: qcs.length + 1,
        itemBuilder: (ctx, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text('Recent Quality Checks', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            );
          }
          final qc = qcs[i - 1];
          final isPass = qc['status'] == 'Pass';
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: isPass ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                child: Icon(isPass ? Icons.check_circle_rounded : Icons.cancel_rounded, color: isPass ? Colors.green : Colors.red),
              ),
              title: Text(qc['lot']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Inspector: ${qc['inspector']} • ${qc['time']}'),
              trailing: FilledButton.tonal(
                onPressed: () {},
                child: const Text('View Report'),
              ),
            ),
          );
        },
      ),
    );
  }
}

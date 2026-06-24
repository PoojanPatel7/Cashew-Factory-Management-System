import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CertificatesTab extends StatelessWidget {
  const CertificatesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final certs = [
      {'id': 'CERT-26-005', 'lot': 'LOT-2026-101', 'date': '24-Jun-2026'},
      {'id': 'CERT-26-004', 'lot': 'LOT-2026-098', 'date': '24-Jun-2026'},
      {'id': 'CERT-26-003', 'lot': 'LOT-2026-095', 'date': '23-Jun-2026'},
    ];

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: certs.length + 1,
        itemBuilder: (ctx, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text('Quality Certificates', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            );
          }
          final cert = certs[i - 1];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.picture_as_pdf_rounded, color: theme.colorScheme.primary),
              ),
              title: Text(cert['id']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Lot: ${cert['lot']} • Issued: ${cert['date']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
                  FilledButton.tonal(
                    onPressed: () => context.push('/grading/certificate_pdf'),
                    child: const Text('View PDF'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

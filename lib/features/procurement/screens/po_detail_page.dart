import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/payment_dialog.dart';
import '../../../shared/widgets/common_widgets.dart';

class PoDetailPage extends StatelessWidget {
  final Map<String, dynamic>? poData;

  const PoDetailPage({super.key, this.poData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Demo data if not provided
    final data = poData ?? {
      'id': 'PO-2024-001',
      'supplier': 'Rajan Cashew Farm',
      'date': '24-Jun-2026',
      'qty': '5000',
      'amount': '450000',
      'status': 'In Transit',
      'paid': '150000',
      'balance': '300000',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Purchase Order: ${data['id']}'),
        actions: [
          if (data['status'] == 'In Transit' || data['status'] == 'Confirmed')
            TextButton.icon(
              onPressed: () => context.push('/procurement/goods_receipt', extra: data),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Receive Goods'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusTimeline(theme, data['status']),
                const SizedBox(height: 32),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildDetailsCard(theme, data)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildPaymentCard(context, theme, data)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(ThemeData theme, String currentStatus) {
    final statuses = ['Draft', 'Confirmed', 'In Transit', 'Received', 'Closed'];
    final currentIndex = statuses.indexOf(currentStatus);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Status', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Row(
            children: List.generate(statuses.length * 2 - 1, (index) {
              if (index % 2 != 0) {
                // Line
                final stepIndex = index ~/ 2;
                final isCompleted = stepIndex < currentIndex;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                );
              }
              // Node
              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex <= currentIndex;
              final isActive = stepIndex == currentIndex;
              
              return Column(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? theme.colorScheme.primary : Colors.transparent,
                      border: Border.all(
                        color: isCompleted ? theme.colorScheme.primary : theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: isCompleted 
                        ? Icon(Icons.check, size: 16, color: theme.colorScheme.onPrimary)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statuses[stepIndex],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ThemeData theme, Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              StatusBadge(label: data['status'], color: const Color(0xFFFF9100)),
            ],
          ),
          const Divider(height: 32),
          _infoRow(theme, 'Supplier', data['supplier']),
          _infoRow(theme, 'Date Created', data['date']),
          _infoRow(theme, 'Quantity Expected', '${data['qty']} kg'),
          _infoRow(theme, 'Total Value', '₹${data['amount']}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, ThemeData theme, Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Status', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const Divider(height: 32),
          _infoRow(theme, 'Total Amount', '₹${data['amount']}'),
          _infoRow(theme, 'Paid (Advances)', '₹${data['paid']}', color: const Color(0xFF00E676)),
          const Divider(height: 16),
          _infoRow(theme, 'Balance Due', '₹${data['balance']}', isBold: true, color: const Color(0xFFFF5252)),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => showDialog(
                context: context, 
                builder: (_) => PaymentDialog(poData: data),
              ),
              icon: const Icon(Icons.payment_rounded),
              label: const Text('Add Payment'),
            ),
          )
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.textTheme.bodySmall?.color)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}

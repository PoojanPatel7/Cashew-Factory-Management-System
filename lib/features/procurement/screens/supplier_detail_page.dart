import 'package:flutter/material.dart';

class SupplierDetailPage extends StatelessWidget {
  final Map<String, dynamic>? supplier;

  const SupplierDetailPage({super.key, this.supplier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;
    
    // Default mock data if accessed directly
    final data = supplier ?? {
      'id': 'SUP-001', 'name': 'Rajan Cashew Farm', 'location': 'Kollam, Kerala', 
      'rating': 4.5, 'totalQty': '12,500 kg', 'lastPo': '12-Oct-2024', 'status': 'Active'
    };

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(data['name']),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            isScrollable: !isWide,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.textTheme.bodyMedium?.color,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'Info'),
              Tab(text: 'Purchase History'),
              Tab(text: 'Payments'),
              Tab(text: 'Stats & QC'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInfoTab(theme, data),
            _buildPurchaseHistoryTab(theme),
            _buildPaymentLedgerTab(theme),
            _buildStatsTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(ThemeData theme, Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                child: Text(data['name'][0], style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name'], style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: theme.textTheme.bodySmall?.color),
                        const SizedBox(width: 4),
                        Text(data['location'], style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 18),
                    const SizedBox(width: 4),
                    Text('${data['rating']}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFFF9100))),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          Text('Contact Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _infoRow(theme, Icons.person_outline, 'Contact Person', 'Rajan Pillai'),
          _infoRow(theme, Icons.phone_outlined, 'Phone', '+91 98765 43210'),
          _infoRow(theme, Icons.email_outlined, 'Email', 'rajan@example.com'),
          
          const SizedBox(height: 32),
          Text('Bank Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_rounded, size: 32, color: Colors.blueGrey),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('State Bank of India', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('A/C: XXXX XXXX 1234', style: TextStyle(fontFamily: 'monospace', color: theme.textTheme.bodyMedium?.color)),
                      Text('IFSC: SBIN000XXXX', style: TextStyle(fontFamily: 'monospace', color: theme.textTheme.bodySmall?.color)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Requires Owner/Manager PIN to reveal',
                  icon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFFF5252)),
                  onPressed: () {}, // Trigger Encrypt Engine auth
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: theme.textTheme.bodySmall?.color))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildPurchaseHistoryTab(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (ctx, i) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: ListTile(
          leading: const Icon(Icons.receipt_long_outlined),
          title: Text('PO-2024-00${i + 1}'),
          subtitle: Text('${(i + 1) * 2000} kg • ₹${(i + 1) * 180000}'),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  Widget _buildPaymentLedgerTab(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF00E676).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Column(
                    children: [Text('Total Paid'), SizedBox(height: 8), Text('₹12,50,000', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00E676)))],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFFF5252).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Column(
                    children: [Text('Advance Balance'), SizedBox(height: 8), Text('₹50,000', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF5252)))],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            itemBuilder: (ctx, i) => ListTile(
              leading: const Icon(Icons.payment_outlined),
              title: const Text('Bank Transfer • HDFC'),
              subtitle: const Text('12-Jun-2026'),
              trailing: Text('+ ₹${(i + 1) * 50000}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E676))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quality Metrics (YTD)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statCircle(theme, 'Average Moisture', '8.5%', Colors.blue),
              _statCircle(theme, 'Grade A Yield', '72%', Colors.green),
              _statCircle(theme, 'Rejection Rate', '1.2%', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCircle(ThemeData theme, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 4),
          ),
          child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 12),
        Text(label, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
      ],
    );
  }
}

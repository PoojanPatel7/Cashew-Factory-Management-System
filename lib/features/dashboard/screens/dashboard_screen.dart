import 'package:flutter/material.dart';
import '../../../shared/widgets/common_widgets.dart';

/// Main dashboard — command center with factory overview widgets (theme-aware)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isWide = MediaQuery.of(context).size.width > 800;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome
          if (!isWide) ...[
            const SizedBox(height: 4),
            Text('Dashboard', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 2),
            Text('Welcome back, Factory Owner', style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),

          // Quick Stats
          _buildQuickStats(context, theme, cs, isWide),
          const SizedBox(height: 20),

          // Processing Pipeline
          SectionHeader(title: 'Processing Pipeline', actionLabel: 'View All', onAction: () {}),
          _buildPipeline(theme, cs),
          const SizedBox(height: 20),

          // Bottom
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildAlerts(theme, cs)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildMachines(theme, cs)),
              ],
            )
          else ...[
            _buildAlerts(theme, cs),
            const SizedBox(height: 16),
            _buildMachines(theme, cs),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, ThemeData theme, ColorScheme cs, bool isWide) {
    final stats = [
      _Stat(Icons.inventory_2_rounded, 'RCN Stock', '12,500 kg', '+2,000 today', const Color(0xFF448AFF)),
      _Stat(Icons.precision_manufacturing_rounded, "Today's Output", '1,850 kg', '23.2% outturn', const Color(0xFF00E676)),
      _Stat(Icons.point_of_sale_rounded, 'Revenue (Month)', '₹18.5L', '+12% vs last', cs.primary),
      _Stat(Icons.people_rounded, 'Attendance', '142/156', '91% present', const Color(0xFF18FFFF)),
    ];

    if (isWide) {
      return Row(
        children: stats.map((s) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _statCard(theme, cs, s),
          ),
        )).toList(),
      );
    }

    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5,
      children: stats.map((s) => _statCard(theme, cs, s)).toList(),
    );
  }

  Widget _statCard(ThemeData theme, ColorScheme cs, _Stat s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(s.icon, color: s.color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.trending_up_rounded, color: const Color(0xFF00E676), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(s.value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: theme.textTheme.bodyLarge?.color)),
          const SizedBox(height: 2),
          Text(s.label, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
          Text(s.trend, style: TextStyle(color: s.color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPipeline(ThemeData theme, ColorScheme cs) {
    final stages = [
      ('Cleaning', 3, const Color(0xFF00E676)),
      ('Steam', 2, cs.primary),
      ('Shelling', 4, cs.primary),
      ('Drying', 1, const Color(0xFFFFD54F)),
      ('Peeling', 2, cs.primary),
      ('Grading', 1, const Color(0xFF78909C)),
      ('Packing', 0, const Color(0xFF78909C)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: stages.map((s) {
            return Container(
              width: 100, margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: s.$3.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: s.$3.withValues(alpha: 0.5)),
                    ),
                    child: Center(child: Text('${s.$2}',
                      style: TextStyle(color: s.$3, fontWeight: FontWeight.w700, fontSize: 18))),
                  ),
                  const SizedBox(height: 8),
                  Text(s.$1, style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color), textAlign: TextAlign.center),
                  Text('${s.$2} lots', style: TextStyle(fontSize: 10, color: s.$3)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAlerts(ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.warning_amber_rounded, color: const Color(0xFFFF9100), size: 20),
            const SizedBox(width: 8),
            Text('Recent Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
          ]),
          const SizedBox(height: 12),
          _alert(theme, Icons.inventory_2, 'Low Stock: Packaging tins', 'Only 50 units left', const Color(0xFFFF5252)),
          _alert(theme, Icons.build, 'Maintenance Due: Borma Dryer #2', 'Scheduled for tomorrow', const Color(0xFFFF9100)),
          _alert(theme, Icons.verified, 'FSSAI License expiring', 'Renewal due in 15 days', const Color(0xFFFF9100)),
          _alert(theme, Icons.check_circle, 'Lot #2024-087 completed', 'Ready for dispatch', const Color(0xFF00E676)),
        ],
      ),
    );
  }

  Widget _alert(ThemeData theme, IconData icon, String title, String sub, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.textTheme.bodyLarge?.color)),
              Text(sub, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildMachines(ThemeData theme, ColorScheme cs) {
    final machines = [
      ('Steam Boiler', true, 'Running'), ('Shelling Line A', true, 'Running'),
      ('Shelling Line B', false, 'Idle'), ('Borma Dryer #1', true, 'Running'),
      ('Borma Dryer #2', false, 'Maintenance'), ('Color Sorter', true, 'Running'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.build_circle_rounded, color: const Color(0xFF18FFFF), size: 20),
            const SizedBox(width: 8),
            Text('Machines', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
          ]),
          const SizedBox(height: 16),
          ...machines.map((m) {
            final color = m.$3 == 'Running' ? const Color(0xFF00E676) :
                          m.$3 == 'Idle' ? const Color(0xFFFFD54F) : const Color(0xFFFF9100);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(child: Text(m.$1, style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color))),
                  StatusBadge(label: m.$3, color: color),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Stat {
  final IconData icon; final String label, value, trend; final Color color;
  _Stat(this.icon, this.label, this.value, this.trend, this.color);
}

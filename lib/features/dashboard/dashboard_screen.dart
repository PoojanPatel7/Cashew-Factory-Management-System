import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/stock_providers.dart';
import '../auth/providers/auth_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/logout_action.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);
    final isOwner = authState.role == 'OWNER';
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 48),
            const SizedBox(width: 12),
            const Text('HM Nuts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: 0.5)),
          ],
        ),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.person_add_rounded),
              onPressed: () => _showAddEmployeeDialog(context),
            ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.refresh(dashboardProvider),
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 64, color: cs.error),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Database Error: ${e.toString()}', style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(dashboardProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          final raw = data['rawStock'] as Map<String, dynamic>;
          final proc = data['processing'] as Map<String, dynamic>;
          final fin = data['finished'] as Map<String, dynamic>;
          final activity = data['recentActivity'] as List<dynamic>;

          Widget buildHero() {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primaryContainer, cs.secondaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: cs.primary.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome Back!', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: cs.onPrimaryContainer)),
                  const SizedBox(height: 4),
                  Text('Here is your factory overview for today.', style: TextStyle(color: cs.onPrimaryContainer.withValues(alpha: 0.8))),
                ],
              ),
            );
          }

          List<Widget> buildMainCards() {
            return [
              _SummaryCard(
                title: 'Raw Stock',
                value: '${_fmt(raw['available'])} kg',
                icon: Icons.inventory_2_rounded,
                color: Colors.orange,
                subtitle: '${_fmt(raw['total'])} kg received',
                onTap: () => context.go('/raw-stock'),
              ),
              _SummaryCard(
                title: 'Processing',
                value: '${proc['active']} Lots',
                icon: Icons.precision_manufacturing_rounded,
                color: Colors.blue,
                subtitle: '${_fmt(proc['activeWeight'])} kg active',
                onTap: () => context.go('/processing'),
              ),
              _SummaryCard(
                title: 'Finished',
                value: '${_fmt(fin['available'])} kg',
                icon: Icons.check_circle_rounded,
                color: Colors.green,
                subtitle: 'Ready to dispatch',
                onTap: () => context.go('/finished'),
              ),
            ];
          }

          List<Widget> buildSecondaryCards() {
            return [
              _SummaryCard(
                title: 'Pending',
                value: '${proc['pending']}',
                icon: Icons.hourglass_empty_rounded,
                color: Colors.amber,
                subtitle: 'Lots waiting',
                compact: true,
              ),
              _SummaryCard(
                title: 'Dispatched',
                value: '${_fmt(fin['totalDispatched'])} kg',
                icon: Icons.local_shipping_rounded,
                color: Colors.purple,
                subtitle: 'Sent out',
                compact: true,
              ),
              _SummaryCard(
                title: 'Waste',
                value: 'View',
                icon: Icons.delete_sweep_rounded,
                color: Colors.red,
                subtitle: 'Track waste',
                compact: true,
                onTap: () => context.push('/wastage'),
              ),
            ];
          }

          Widget buildActivity() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Activity', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (activity.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.history_rounded, size: 48, color: cs.outline),
                            const SizedBox(height: 12),
                            Text('No activity yet', style: TextStyle(color: cs.outline)),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...activity.map((a) => _ActivityTile(
                    action: a['action'] ?? '',
                    detail: a['detail'] ?? '',
                    weight: (a['weight'] as num?)?.toDouble(),
                    timestamp: a['timestamp'] ?? '',
                  )),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardProvider),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                if (isWide) {
                  // Two-Column Layout for PC
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildHero(),
                              const SizedBox(height: 24),
                              GridView.count(
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1.1,
                                children: buildMainCards(),
                              ),
                              const SizedBox(height: 16),
                              GridView.count(
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1.5,
                                children: buildSecondaryCards(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(width: 1, color: theme.dividerColor),
                      Expanded(
                        flex: 2,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: buildActivity(),
                        ),
                      ),
                    ],
                  );
                }

                // Stacked / Grid layout for Mobile
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHero(),
                      const SizedBox(height: 24),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.9,
                        children: buildMainCards(),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.8,
                        children: buildSecondaryCards(),
                      ),
                      const SizedBox(height: 28),
                      buildActivity(),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _fmt(dynamic val) {
    if (val == null) return '0';
    final d = (val is num) ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    return d == d.roundToDouble() ? d.toInt().toString() : d.toStringAsFixed(1);
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Employee'),
        content: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
                validator: (v) => v == null || v.length < 6 ? 'Min 6 chars' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                FirebaseApp tempApp = await Firebase.initializeApp(name: 'temp', options: Firebase.app().options);
                final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
                final cred = await tempAuth.createUserWithEmailAndPassword(email: emailCtrl.text.trim(), password: passCtrl.text);
                await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
                  'email': emailCtrl.text.trim(),
                  'name': nameCtrl.text.trim(),
                  'role': 'WORKER',
                  'isEmployee': true,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                await tempApp.delete();
                
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Employee added successfully!')));
                }
              } catch (e) {
                if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Failed: $e')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Card Widget ────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool compact;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.05), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(compact ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: compact ? 22 : 28),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                        ]
                      ),
                      child: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline, size: 20),
                    ),
                ],
              ),
              const Spacer(),
              Text(title, style: TextStyle(fontSize: compact ? 13 : 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: TextStyle(fontSize: compact ? 24 : 32, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: compact ? 11 : 13, color: theme.colorScheme.outline)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Activity Tile Widget ───────────────────────────────────
class _ActivityTile extends StatelessWidget {
  final String action, detail, timestamp;
  final double? weight;

  const _ActivityTile({required this.action, required this.detail, required this.timestamp, this.weight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;
    switch (action) {
      case 'STOCK_ADDED': icon = Icons.add_circle_rounded; color = Colors.orange; break;
      case 'SORTING_DONE': icon = Icons.call_split_rounded; color = Colors.indigo; break;
      case 'LOT_STARTED': icon = Icons.play_circle_rounded; color = Colors.blue; break;
      case 'STAGE_COMPLETED': icon = Icons.check_circle_outline_rounded; color = Colors.teal; break;
      case 'LOT_COMPLETED': icon = Icons.verified_rounded; color = Colors.green; break;
      case 'STOCK_DISPATCHED': icon = Icons.local_shipping_rounded; color = Colors.purple; break;
      default: icon = Icons.info_rounded; color = Colors.grey;
    }

    final dateStr = timestamp.split('T').first;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(detail, style: const TextStyle(fontSize: 14)),
        subtitle: Text(dateStr, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
        trailing: weight != null
            ? Text('${weight!.toStringAsFixed(1)} kg',
                style: TextStyle(fontWeight: FontWeight.bold, color: color))
            : null,
      ),
    );
  }
}

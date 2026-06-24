import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'grade_dashboard_tab.dart';
import 'qc_checklist_tab.dart';
import 'certificates_tab.dart';

class QualityHubScreen extends StatelessWidget {
  const QualityHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quality Control & Grading'),
          bottom: TabBar(
            isScrollable: !isWide,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.textTheme.bodyMedium?.color,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.pie_chart_rounded), text: 'Grade Dashboard'),
              Tab(icon: Icon(Icons.checklist_rtl_rounded), text: 'QC Checklists'),
              Tab(icon: Icon(Icons.verified_user_rounded), text: 'Certificates'),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New QC Entry'),
                onPressed: () => context.push('/grading/qc_entry'),
              ),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            GradeDashboardTab(),
            QCChecklistTab(),
            CertificatesTab(),
          ],
        ),
      ),
    );
  }
}

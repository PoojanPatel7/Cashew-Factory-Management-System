import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'processing_dashboard_tab.dart';
import 'kanban_board_tab.dart';
import 'lot_list_tab.dart';
import 'yield_reports_tab.dart';

class ProcessingHubScreen extends StatelessWidget {
  const ProcessingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Live Processing'),
          bottom: TabBar(
            isScrollable: !isWide,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.textTheme.bodyMedium?.color,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(icon: Icon(Icons.dashboard_rounded), text: 'Dashboard'),
              Tab(icon: Icon(Icons.view_kanban_rounded), text: 'Kanban Board'),
              Tab(icon: Icon(Icons.format_list_bulleted_rounded), text: 'Lot List'),
              Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Yield & Reports'),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ActionChip(
                avatar: const Icon(Icons.schedule, size: 16),
                label: const Text('Shift: Morning'),
                onPressed: () {
                  context.push('/processing/daily_summary');
                },
              ),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            ProcessingDashboardTab(),
            KanbanBoardTab(),
            LotListTab(),
            YieldReportsTab(),
          ],
        ),
      ),
    );
  }
}

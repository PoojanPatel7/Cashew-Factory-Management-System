import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/setup_wizard_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../shared/widgets/app_scaffold.dart';

/// CashewPro ERP — App Router Configuration
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // ── Auth Routes ──
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/setup',
      name: 'setup',
      builder: (context, state) => const SetupWizardScreen(),
    ),

    // ── Main App Shell ──
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/procurement',
          name: 'procurement',
          builder: (context, state) => const _ComingSoonScreen(title: 'Procurement'),
        ),
        GoRoute(
          path: '/inventory',
          name: 'inventory',
          builder: (context, state) => const _ComingSoonScreen(title: 'Inventory'),
        ),
        GoRoute(
          path: '/processing',
          name: 'processing',
          builder: (context, state) => const _ComingSoonScreen(title: 'Live Processing'),
        ),
        GoRoute(
          path: '/grading',
          name: 'grading',
          builder: (context, state) => const _ComingSoonScreen(title: 'Grading & QC'),
        ),
        GoRoute(
          path: '/employees',
          name: 'employees',
          builder: (context, state) => const _ComingSoonScreen(title: 'Employees'),
        ),
        GoRoute(
          path: '/accounting',
          name: 'accounting',
          builder: (context, state) => const _ComingSoonScreen(title: 'Accounting'),
        ),
        GoRoute(
          path: '/sales',
          name: 'sales',
          builder: (context, state) => const _ComingSoonScreen(title: 'Sales & Dispatch'),
        ),
        GoRoute(
          path: '/byproducts',
          name: 'byproducts',
          builder: (context, state) => const _ComingSoonScreen(title: 'Byproducts'),
        ),
        GoRoute(
          path: '/compliance',
          name: 'compliance',
          builder: (context, state) => const _ComingSoonScreen(title: 'Compliance'),
        ),
        GoRoute(
          path: '/machinery',
          name: 'machinery',
          builder: (context, state) => const _ComingSoonScreen(title: 'Machinery Portal'),
        ),
        GoRoute(
          path: '/reports',
          name: 'reports',
          builder: (context, state) => const _ComingSoonScreen(title: 'Reports'),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

/// Placeholder screen for modules not yet built
class _ComingSoonScreen extends StatelessWidget {
  final String title;
  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 72,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Coming in next update',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

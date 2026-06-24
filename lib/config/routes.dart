import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/setup_wizard_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/procurement/screens/procurement_hub_screen.dart';
import '../features/procurement/screens/supplier_detail_page.dart';
import '../features/procurement/screens/add_supplier_page.dart';
import '../features/procurement/screens/create_po_page.dart';
import '../features/procurement/screens/po_detail_page.dart';
import '../features/procurement/screens/goods_receipt_page.dart';
import '../features/inventory/screens/inventory_hub_screen.dart';
import '../features/inventory/screens/stock_adjustment_page.dart';
import '../features/processing/screens/processing_hub_screen.dart';
import '../features/processing/screens/create_lot_page.dart';
import '../features/processing/screens/lot_detail_page.dart';
import '../features/processing/screens/daily_summary_page.dart';
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
          builder: (context, state) => const ProcurementHubScreen(),
          routes: [
            GoRoute(
              path: 'supplier_detail',
              name: 'supplier_detail',
              builder: (context, state) {
                final supplier = state.extra as Map<String, dynamic>?;
                return SupplierDetailPage(supplier: supplier);
              },
            ),
            GoRoute(
              path: 'add_supplier',
              name: 'add_supplier',
              builder: (context, state) => const AddSupplierPage(),
            ),
            GoRoute(
              path: 'create_po',
              name: 'create_po',
              builder: (context, state) => const CreatePoPage(),
            ),
            GoRoute(
              path: 'po_detail',
              name: 'po_detail',
              builder: (context, state) {
                final poData = state.extra as Map<String, dynamic>?;
                return PoDetailPage(poData: poData);
              },
            ),
            GoRoute(
              path: 'goods_receipt',
              name: 'goods_receipt',
              builder: (context, state) {
                final poData = state.extra as Map<String, dynamic>?;
                return GoodsReceiptPage(poData: poData);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/inventory',
          name: 'inventory',
          builder: (context, state) => const InventoryHubScreen(),
          routes: [
            GoRoute(
              path: 'adjust',
              name: 'stock_adjust',
              builder: (context, state) => const StockAdjustmentPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/processing',
          name: 'processing',
          builder: (context, state) => const ProcessingHubScreen(),
          routes: [
            GoRoute(
              path: 'create_lot',
              name: 'create_lot',
              builder: (context, state) => const CreateLotPage(),
            ),
            GoRoute(
              path: 'lot_detail',
              name: 'lot_detail',
              builder: (context, state) {
                final lotData = state.extra as Map<String, dynamic>?;
                return LotDetailPage(lotData: lotData);
              },
            ),
            GoRoute(
              path: 'daily_summary',
              name: 'daily_summary',
              builder: (context, state) => const DailySummaryPage(),
            ),
          ],
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

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
import '../features/quality/screens/quality_hub_screen.dart';
import '../features/quality/screens/grading_entry_page.dart';
import '../features/quality/screens/qc_entry_page.dart';
import '../features/quality/screens/quality_certificate_page.dart';
import '../features/hr/screens/employee_hub_screen.dart';
import '../features/hr/screens/employee_detail_page.dart';
import '../features/hr/screens/add_employee_page.dart';
import '../features/hr/screens/attendance_dashboard_page.dart';
import '../features/hr/screens/self_checkin_page.dart';
import '../features/hr/screens/attendance_calendar_page.dart';
import '../features/hr/screens/leave_application_page.dart';
import '../features/hr/screens/advance_management_page.dart';
import '../features/hr/screens/piece_work_entry_page.dart';
import '../features/hr/screens/piece_work_daily_log_page.dart';
import '../features/hr/screens/payroll_generation_page.dart';
import '../features/hr/screens/payslip_page.dart';
import '../features/accounting/screens/accounting_dashboard_page.dart';
import '../features/accounting/screens/ledger_page.dart';
import '../features/accounting/screens/expense_list_page.dart';
import '../features/accounting/screens/add_expense_page.dart';
import '../features/accounting/screens/cash_book_page.dart';
import '../features/accounting/screens/bank_account_page.dart';
import '../features/accounting/screens/trial_balance_page.dart';
import '../features/accounting/screens/gst_dashboard_page.dart';
import '../features/accounting/screens/gst_invoice_page.dart';
import '../features/accounting/screens/pnl_report_page.dart';
import '../features/accounting/screens/lot_profitability_page.dart';
import '../features/accounting/screens/grade_profitability_page.dart';
import '../features/accounting/screens/outstanding_page.dart';
import '../features/sales/screens/sales_hub_screen.dart';
import '../features/sales/screens/customer_list_page.dart';
import '../features/sales/screens/customer_detail_page.dart';
import '../features/sales/screens/create_sales_order_page.dart';
import '../features/sales/screens/sales_order_detail_page.dart';
import '../features/sales/screens/invoice_list_page.dart';
import '../features/sales/screens/price_list_page.dart';
import '../features/sales/screens/dispatch_dashboard_page.dart';
import '../features/sales/screens/create_dispatch_page.dart';
import '../features/sales/screens/dispatch_tracking_page.dart';
import '../features/sales/screens/export_docs_page.dart';
import '../features/byproducts/screens/byproduct_dashboard_page.dart';
import '../features/byproducts/screens/byproduct_sale_page.dart';
import '../features/byproducts/screens/cnsl_extraction_log_page.dart';
import '../features/byproducts/screens/waste_disposal_log_page.dart';
import '../features/compliance/screens/compliance_dashboard_page.dart';
import '../features/compliance/screens/document_list_page.dart';
import '../features/compliance/screens/add_document_page.dart';
import '../features/compliance/screens/document_detail_page.dart';
import '../features/machinery/screens/machinery_dashboard_page.dart';
import '../features/machinery/screens/machine_list_page.dart';
import '../features/machinery/screens/add_machine_page.dart';
import '../features/machinery/screens/machine_detail_page.dart';
import '../features/machinery/screens/maintenance_calendar_page.dart';
import '../features/machinery/screens/schedule_maintenance_page.dart';
import '../features/machinery/screens/maintenance_log_entry_page.dart';
import '../features/machinery/screens/spare_parts_list_page.dart';
import '../features/machinery/screens/add_spare_part_page.dart';
import '../features/machinery/screens/machine_analytics_page.dart';
import '../features/dashboard/screens/role_dashboards.dart';
import '../features/reports/screens/reports_hub_page.dart';
import '../features/reports/screens/report_viewer_page.dart';
import '../features/notifications/screens/notification_center_page.dart';
import '../features/help/screens/help_faq_page.dart';
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
          path: '/manager_dashboard',
          name: 'manager_dashboard',
          builder: (context, state) => const ManagerDashboardPage(),
        ),
        GoRoute(
          path: '/supervisor_dashboard',
          name: 'supervisor_dashboard',
          builder: (context, state) => const SupervisorDashboardPage(),
        ),
        GoRoute(
          path: '/accountant_dashboard',
          name: 'accountant_dashboard',
          builder: (context, state) => const AccountantDashboardPage(),
        ),
        GoRoute(
          path: '/operator_dashboard',
          name: 'operator_dashboard',
          builder: (context, state) => const OperatorDashboardPage(),
        ),
        GoRoute(
          path: '/worker_dashboard',
          name: 'worker_dashboard',
          builder: (context, state) => const WorkerDashboardPage(),
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
          builder: (context, state) => const QualityHubScreen(),
          routes: [
            GoRoute(
              path: 'grading_entry',
              name: 'grading_entry',
              builder: (context, state) => const GradingEntryPage(),
            ),
            GoRoute(
              path: 'qc_entry',
              name: 'qc_entry',
              builder: (context, state) => const QCEntryPage(),
            ),
            GoRoute(
              path: 'certificate_pdf',
              name: 'certificate_pdf',
              builder: (context, state) => const QualityCertificatePage(),
            ),
          ],
        ),
        GoRoute(
          path: '/employees',
          name: 'employees',
          builder: (context, state) => const EmployeeHubScreen(),
          routes: [
            GoRoute(
              path: 'add_employee',
              name: 'add_employee',
              builder: (context, state) => const AddEmployeePage(),
            ),
            GoRoute(
              path: 'employee_detail',
              name: 'employee_detail',
              builder: (context, state) {
                final emp = state.extra as Map<String, dynamic>?;
                return EmployeeDetailPage(employee: emp);
              },
            ),
            GoRoute(
              path: 'attendance',
              name: 'attendance_dashboard',
              builder: (context, state) => const AttendanceDashboardPage(),
            ),
            GoRoute(
              path: 'self_checkin',
              name: 'self_checkin',
              builder: (context, state) => const SelfCheckinPage(),
            ),
            GoRoute(
              path: 'attendance_calendar',
              name: 'attendance_calendar',
              builder: (context, state) => const AttendanceCalendarPage(),
            ),
            GoRoute(
              path: 'leave_application',
              name: 'leave_application',
              builder: (context, state) => const LeaveApplicationPage(),
            ),
            GoRoute(
              path: 'advance_management',
              name: 'advance_management',
              builder: (context, state) => const AdvanceManagementPage(),
            ),
            GoRoute(
              path: 'piece_work_entry',
              name: 'piece_work_entry',
              builder: (context, state) => const PieceWorkEntryPage(),
            ),
            GoRoute(
              path: 'piece_work_log',
              name: 'piece_work_log',
              builder: (context, state) => const PieceWorkDailyLogPage(),
            ),
            GoRoute(
              path: 'payroll_generation',
              name: 'payroll_generation',
              builder: (context, state) => const PayrollGenerationPage(),
            ),
            GoRoute(
              path: 'payslip',
              name: 'payslip',
              builder: (context, state) => const PayslipPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/accounting',
          name: 'accounting',
          builder: (context, state) => const AccountingDashboardPage(),
          routes: [
            GoRoute(
              path: 'ledger',
              name: 'ledger',
              builder: (context, state) => const LedgerPage(),
            ),
            GoRoute(
              path: 'expense_list',
              name: 'expense_list',
              builder: (context, state) => const ExpenseListPage(),
            ),
            GoRoute(
              path: 'add_expense',
              name: 'add_expense',
              builder: (context, state) => const AddExpensePage(),
            ),
            GoRoute(
              path: 'cash_book',
              name: 'cash_book',
              builder: (context, state) => const CashBookPage(),
            ),
            GoRoute(
              path: 'bank_account',
              name: 'bank_account',
              builder: (context, state) => const BankAccountPage(),
            ),
            GoRoute(
              path: 'trial_balance',
              name: 'trial_balance',
              builder: (context, state) => const TrialBalancePage(),
            ),
            GoRoute(
              path: 'gst_dashboard',
              name: 'gst_dashboard',
              builder: (context, state) => const GstDashboardPage(),
            ),
            GoRoute(
              path: 'gst_invoice',
              name: 'gst_invoice',
              builder: (context, state) => const GstInvoicePage(),
            ),
            GoRoute(
              path: 'pnl_report',
              name: 'pnl_report',
              builder: (context, state) => const PnlReportPage(),
            ),
            GoRoute(
              path: 'lot_profitability',
              name: 'lot_profitability',
              builder: (context, state) => const LotProfitabilityPage(),
            ),
            GoRoute(
              path: 'grade_profitability',
              name: 'grade_profitability',
              builder: (context, state) => const GradeProfitabilityPage(),
            ),
            GoRoute(
              path: 'outstanding',
              name: 'outstanding',
              builder: (context, state) => const OutstandingPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/sales',
          name: 'sales',
          builder: (context, state) => const SalesHubScreen(),
          routes: [
            GoRoute(
              path: 'customer_list',
              name: 'customer_list',
              builder: (context, state) => const CustomerListPage(),
            ),
            GoRoute(
              path: 'customer_detail',
              name: 'customer_detail',
              builder: (context, state) => const CustomerDetailPage(),
            ),
            GoRoute(
              path: 'create_sales_order',
              name: 'create_sales_order',
              builder: (context, state) => const CreateSalesOrderPage(),
            ),
            GoRoute(
              path: 'sales_order_detail',
              name: 'sales_order_detail',
              builder: (context, state) => const SalesOrderDetailPage(),
            ),
            GoRoute(
              path: 'invoice_list',
              name: 'invoice_list',
              builder: (context, state) => const InvoiceListPage(),
            ),
            GoRoute(
              path: 'price_list',
              name: 'price_list',
              builder: (context, state) => const PriceListPage(),
            ),
            GoRoute(
              path: 'dispatch_dashboard',
              name: 'dispatch_dashboard',
              builder: (context, state) => const DispatchDashboardPage(),
            ),
            GoRoute(
              path: 'create_dispatch',
              name: 'create_dispatch',
              builder: (context, state) => const CreateDispatchPage(),
            ),
            GoRoute(
              path: 'dispatch_tracking',
              name: 'dispatch_tracking',
              builder: (context, state) => const DispatchTrackingPage(),
            ),
            GoRoute(
              path: 'export_docs',
              name: 'export_docs',
              builder: (context, state) => const ExportDocsPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/byproducts',
          name: 'byproducts',
          builder: (context, state) => const ByproductDashboardPage(),
          routes: [
            GoRoute(
              path: 'byproduct_sale',
              name: 'byproduct_sale',
              builder: (context, state) => const ByproductSalePage(),
            ),
            GoRoute(
              path: 'cnsl_extraction',
              name: 'cnsl_extraction',
              builder: (context, state) => const CnslExtractionLogPage(),
            ),
            GoRoute(
              path: 'waste_log',
              name: 'waste_log',
              builder: (context, state) => const WasteDisposalLogPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/compliance',
          name: 'compliance',
          builder: (context, state) => const ComplianceDashboardPage(),
          routes: [
            GoRoute(
              path: 'document_list',
              name: 'document_list',
              builder: (context, state) => const DocumentListPage(),
            ),
            GoRoute(
              path: 'add_document',
              name: 'add_document',
              builder: (context, state) => const AddDocumentPage(),
            ),
            GoRoute(
              path: 'document_detail',
              name: 'document_detail',
              builder: (context, state) => const DocumentDetailPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/machinery',
          name: 'machinery',
          builder: (context, state) => const MachineryDashboardPage(),
          routes: [
            GoRoute(
              path: 'machine_list',
              name: 'machine_list',
              builder: (context, state) => const MachineListPage(),
            ),
            GoRoute(
              path: 'add_machine',
              name: 'add_machine',
              builder: (context, state) => const AddMachinePage(),
            ),
            GoRoute(
              path: 'machine_detail',
              name: 'machine_detail',
              builder: (context, state) => const MachineDetailPage(),
            ),
            GoRoute(
              path: 'maintenance_calendar',
              name: 'maintenance_calendar',
              builder: (context, state) => const MaintenanceCalendarPage(),
            ),
            GoRoute(
              path: 'schedule_maintenance',
              name: 'schedule_maintenance',
              builder: (context, state) => const ScheduleMaintenancePage(),
            ),
            GoRoute(
              path: 'maintenance_log',
              name: 'maintenance_log',
              builder: (context, state) => const MaintenanceLogEntryPage(),
            ),
            GoRoute(
              path: 'spare_parts',
              name: 'spare_parts',
              builder: (context, state) => const SparePartsListPage(),
            ),
            GoRoute(
              path: 'add_spare_part',
              name: 'add_spare_part',
              builder: (context, state) => const AddSparePartPage(),
            ),
            GoRoute(
              path: 'machine_analytics',
              name: 'machine_analytics',
              builder: (context, state) => const MachineAnalyticsPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/reports',
          name: 'reports',
          builder: (context, state) => const ReportsHubPage(),
          routes: [
            GoRoute(
              path: 'report_viewer',
              name: 'report_viewer',
              builder: (context, state) {
                final reportName = state.uri.queryParameters['reportName'] ?? 'Report';
                return ReportViewerPage(reportName: reportName);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationCenterPage(),
        ),
        GoRoute(
          path: '/help',
          name: 'help',
          builder: (context, state) => const HelpFaqPage(),
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

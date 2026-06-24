/// User roles for the CashewPro RBAC system
enum UserRole {
  owner,
  manager,
  supervisor,
  accountant,
  operator,
  worker,
}

/// Extension for display names and permissions
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.owner: return 'Owner';
      case UserRole.manager: return 'Manager';
      case UserRole.supervisor: return 'Supervisor';
      case UserRole.accountant: return 'Accountant';
      case UserRole.operator: return 'Operator';
      case UserRole.worker: return 'Worker';
    }
  }

  String get description {
    switch (this) {
      case UserRole.owner: return 'Full access to all modules and settings';
      case UserRole.manager: return 'All modules except settings and security';
      case UserRole.supervisor: return 'Processing, inventory, grading, team management';
      case UserRole.accountant: return 'Accounting, sales, financial reports';
      case UserRole.operator: return 'Assigned machines and processing stage';
      case UserRole.worker: return 'Own attendance, earnings, and payslips';
    }
  }

  /// Modules this role can see in navigation
  List<String> get allowedModules {
    switch (this) {
      case UserRole.owner:
        return [
          '/', '/procurement', '/inventory', '/processing', '/grading',
          '/employees', '/accounting', '/sales', '/byproducts', '/compliance',
          '/machinery', '/reports', '/settings',
        ];
      case UserRole.manager:
        return [
          '/', '/procurement', '/inventory', '/processing', '/grading',
          '/employees', '/accounting', '/sales', '/byproducts', '/compliance',
          '/machinery', '/reports',
        ];
      case UserRole.supervisor:
        return [
          '/', '/processing', '/inventory', '/grading', '/employees',
          '/machinery',
        ];
      case UserRole.accountant:
        return [
          '/', '/accounting', '/sales', '/procurement', '/reports',
        ];
      case UserRole.operator:
        return ['/', '/machinery', '/processing'];
      case UserRole.worker:
        return ['/'];
    }
  }

  /// Check if this role has a specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  List<String> get permissions {
    switch (this) {
      case UserRole.owner:
        return ['*']; // All permissions
      case UserRole.manager:
        return [
          'procurement.view', 'procurement.create', 'procurement.edit', 'procurement.approve',
          'inventory.view', 'inventory.create', 'inventory.edit',
          'processing.view', 'processing.create', 'processing.edit',
          'grading.view', 'grading.create', 'grading.edit',
          'employees.view', 'employees.create', 'employees.edit',
          'accounting.view',
          'sales.view', 'sales.create', 'sales.edit',
          'byproducts.view', 'byproducts.create',
          'compliance.view', 'compliance.create',
          'machinery.view', 'machinery.create', 'machinery.edit',
          'reports.view', 'reports.export',
          'payroll.generate', 'payroll.approve',
          'dispatch.create', 'dispatch.edit',
          'maintenance.schedule',
        ];
      case UserRole.supervisor:
        return [
          'processing.view', 'processing.create', 'processing.edit', 'processing.approve',
          'inventory.view', 'inventory.edit',
          'grading.view', 'grading.create', 'grading.edit',
          'employees.view_team', 'employees.attendance',
          'machinery.view', 'machinery.log_work', 'machinery.report_breakdown',
        ];
      case UserRole.accountant:
        return [
          'accounting.view', 'accounting.create', 'accounting.edit',
          'sales.view', 'sales.create', 'sales.edit',
          'procurement.view',
          'reports.view', 'reports.export',
          'employees.view_names',
          'payroll.generate',
        ];
      case UserRole.operator:
        return [
          'machinery.view_assigned', 'machinery.log_work', 'machinery.report_breakdown',
          'processing.view_assigned', 'processing.log',
          'attendance.self',
        ];
      case UserRole.worker:
        return [
          'attendance.self', 'attendance.view_own',
          'piecework.view_own',
          'payslip.view_own',
        ];
    }
  }
}

/// Current user session model
class UserSession {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String factoryId;
  final String? avatarUrl;

  const UserSession({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.factoryId,
    this.avatarUrl,
  });

  /// Demo user for development
  factory UserSession.demo({UserRole role = UserRole.owner}) {
    return UserSession(
      id: 'demo-user-001',
      name: 'Factory Owner',
      email: 'owner@cashewpro.com',
      role: role,
      factoryId: 'factory-001',
    );
  }

  bool hasPermission(String permission) {
    if (role == UserRole.owner) return true; // Owner has all permissions
    return role.hasPermission(permission);
  }

  bool canAccessModule(String route) {
    return role.allowedModules.contains(route);
  }
}

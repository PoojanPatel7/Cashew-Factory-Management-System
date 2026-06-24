import 'package:flutter/material.dart';
import '../../../core/auth/user_role.dart';
import '../../../shared/widgets/confirmation_dialog.dart';

/// User Management Page — add/edit/deactivate users with roles
class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _searchCtrl = TextEditingController();
  UserRole? _filterRole;

  // Demo users
  final _users = [
    _DemoUser('Ramesh Patel', 'ramesh@factory.com', UserRole.manager, true),
    _DemoUser('Suresh Kumar', 'suresh@factory.com', UserRole.supervisor, true),
    _DemoUser('Priya Shah', 'priya@factory.com', UserRole.accountant, true),
    _DemoUser('Vijay Solanki', 'vijay@factory.com', UserRole.operator, true),
    _DemoUser('Mahesh Bhai', 'mahesh@factory.com', UserRole.worker, true),
    _DemoUser('Ravi Singh', 'ravi@factory.com', UserRole.worker, false),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 800;

    final filtered = _users.where((u) {
      if (_filterRole != null && u.role != _filterRole) return false;
      if (_searchCtrl.text.isNotEmpty) {
        return u.name.toLowerCase().contains(_searchCtrl.text.toLowerCase());
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddUserDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
      ),
      body: Column(
        children: [
          // Search + filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Role filter chips
                PopupMenuButton<UserRole?>(
                  icon: Icon(Icons.filter_list, color: theme.colorScheme.primary),
                  onSelected: (role) => setState(() => _filterRole = role),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: null, child: Text('All Roles')),
                    ...UserRole.values.map((r) => PopupMenuItem(
                      value: r,
                      child: Text(r.displayName),
                    )),
                  ],
                ),
              ],
            ),
          ),

          // User list
          Expanded(
            child: isWide
                ? _buildDesktopTable(theme, filtered)
                : _buildMobileList(theme, filtered),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(ThemeData theme, List<_DemoUser> users) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(theme.colorScheme.surface),
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: users.map((u) => DataRow(cells: [
          DataCell(Text(u.name)),
          DataCell(Text(u.email)),
          DataCell(_roleBadge(theme, u.role)),
          DataCell(_statusBadge(u.isActive)),
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () {}),
              IconButton(icon: const Icon(Icons.block, size: 18, color: Color(0xFFFF5252)), onPressed: () {}),
            ],
          )),
        ])).toList(),
      ),
    );
  }

  Widget _buildMobileList(ThemeData theme, List<_DemoUser> users) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: users.length,
      itemBuilder: (ctx, i) {
        final u = users[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline, width: 0.5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              child: Text(u.name[0], style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            ),
            title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.email, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                const SizedBox(height: 6),
                Row(children: [_roleBadge(theme, u.role), const SizedBox(width: 8), _statusBadge(u.isActive)]),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _roleBadge(ThemeData theme, UserRole role) {
    final colors = {
      UserRole.owner: const Color(0xFFFFD54F),
      UserRole.manager: const Color(0xFF448AFF),
      UserRole.supervisor: const Color(0xFF00E676),
      UserRole.accountant: const Color(0xFFB388FF),
      UserRole.operator: const Color(0xFF18FFFF),
      UserRole.worker: const Color(0xFF78909C),
    };
    final color = colors[role] ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(role.displayName, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isActive ? const Color(0xFF00E676) : const Color(0xFFFF5252)).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(color: isActive ? const Color(0xFF00E676) : const Color(0xFFFF5252), fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    UserRole selectedRole = UserRole.worker;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final theme = Theme.of(ctx);
          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(
                    color: theme.colorScheme.outline, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 20),
                Text('Add New User', style: theme.textTheme.titleLarge),
                const SizedBox(height: 20),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 14),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 14),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.shield_outlined)),
                  items: UserRole.values.where((r) => r != UserRole.owner).map((r) =>
                    DropdownMenuItem(value: r, child: Text(r.displayName))).toList(),
                  onChanged: (v) => setSheetState(() => selectedRole = v!),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(selectedRole.description,
                    style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ConfirmationDialog.show(
                        context,
                        title: 'Create User',
                        icon: Icons.person_add,
                        fields: [
                          ConfirmField(label: 'Name', value: nameCtrl.text),
                          ConfirmField(label: 'Email', value: emailCtrl.text),
                          ConfirmField(label: 'Role', value: selectedRole.displayName),
                          const ConfirmField(label: 'Password', value: 'Auto-generated (sent via email)'),
                        ],
                        onConfirm: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User created successfully!')),
                          );
                        },
                      );
                    },
                    child: const Text('Create User'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DemoUser {
  final String name, email;
  final UserRole role;
  final bool isActive;
  _DemoUser(this.name, this.email, this.role, this.isActive);
}

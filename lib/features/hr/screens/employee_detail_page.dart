import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hr_provider.dart';

class EmployeeDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? employee;
  
  const EmployeeDetailPage({super.key, this.employee});

  @override
  ConsumerState<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends ConsumerState<EmployeeDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPiiRevealed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  void _deleteEmployee(String id) async {
    final nav = Navigator.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Delete')
          ),
        ],
      )
    );

    if (confirm == true) {
      final success = await ref.read(hrProvider.notifier).deleteEmployee(id);
      if (success) {
        nav.pop(); // Go back to hub
      }
    }
  }

  void _editEmployee(Map<String, dynamic> emp) async {
    final String id = emp['id'] ?? '';
    String name = emp['name'] ?? '';
    String phone = emp['phone'] ?? '';
    String aadhaar = emp['aadhaar'] ?? '';
    String pan = emp['pan'] ?? '';
    String role = emp['type'] ?? 'Worker';
    String dept = emp['department'] ?? 'Shelling';
    String email = emp['email'] ?? '';
    String password = emp['password'] ?? '';
    bool saveFace = emp['faceRegistered'] ?? false;
    bool obscurePassword = true;

    final nav = Navigator.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Employee Profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                    onChanged: (val) => name = val,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: phone,
                    decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                    onChanged: (val) => phone = val,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: email,
                    decoration: const InputDecoration(labelText: 'Login Email', prefixIcon: Icon(Icons.email)),
                    onChanged: (val) => email = val,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: password,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.password),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    onChanged: (val) => password = val,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: aadhaar,
                    decoration: const InputDecoration(labelText: 'Aadhaar (Encrypted)', prefixIcon: Icon(Icons.security)),
                    onChanged: (val) => aadhaar = val,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: pan,
                    decoration: const InputDecoration(labelText: 'PAN (Encrypted)', prefixIcon: Icon(Icons.credit_card)),
                    onChanged: (val) => pan = val,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: ['Worker', 'Operator', 'Supervisor', 'Manager'].contains(role) ? role : 'Worker',
                    decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                    items: ['Worker', 'Operator', 'Supervisor', 'Manager'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) { if (val != null) setState(() => role = val); },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: ['Shelling', 'Peeling', 'Grading', 'Maintenance'].contains(dept) ? dept : 'Shelling',
                    decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                    items: ['Shelling', 'Peeling', 'Grading', 'Maintenance'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) { if (val != null) setState(() => dept = val); },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Save Face Data (Self Check-in)'),
                    value: saveFace,
                    onChanged: (val) => setState(() => saveFace = val),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true), 
                child: const Text('Save Changes')
              ),
            ],
          );
        }
      )
    );

    if (confirm == true) {
      final data = {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'aadhar': aadhaar,
        'pan': pan,
        'role': role,
        'department': dept,
        'faceRegistered': saveFace,
      };
      final success = await ref.read(hrProvider.notifier).updateEmployee(id, data);
      if (success) {
        nav.pop(); // Go back to hub to refresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final emp = widget.employee ?? {};
    final String id = emp['id'] ?? '';
    final String name = emp['name'] ?? 'Unknown';
    final String type = emp['type'] ?? 'Worker';
    final String dept = emp['department'] ?? 'Shelling';
    final String status = emp['status'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'delete') {
                _deleteEmployee(id);
              } else if (val == 'edit') {
                _editEmployee(emp);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Employee', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Attendance'),
            Tab(text: 'Earnings'),
            Tab(text: 'Payslips'),
            Tab(text: 'Advances'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(emp, type, dept, status),
          _buildAttendanceTab(id),
          const Center(child: Text('Earnings Data')),
          const Center(child: Text('Payslips Data')),
          const Center(child: Text('Advances Data')),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab(String id) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.co_present, size: 48, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text('Mark Attendance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Manually mark this employee as present for today.'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      final success = await ref.read(hrProvider.notifier).checkIn(id);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance Marked')));
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark Present Now'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: Center(child: Text('Attendance History goes here')),
          ),
        ],
      ),
    );
  }

  void _setCredentials(BuildContext context, String employeeId, String? currentEmail) async {
    String email = currentEmail ?? '';
    String password = '';
    bool obscurePassword = true;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Set Login Credentials'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Provide an email and password for this user to log in.', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: 'Login Email', border: OutlineInputBorder()),
                  onChanged: (val) => email = val,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password', 
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                  obscureText: obscurePassword,
                  onChanged: (val) => password = val,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true), 
                child: const Text('Save Credentials')
              ),
            ],
          );
        }
      )
    );

    if (confirm == true && email.isNotEmpty && password.isNotEmpty) {
      final success = await ref.read(hrProvider.notifier).setCredentials(employeeId, email, password);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credentials updated successfully!')));
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update credentials')));
      }
    }
  }

  Widget _buildProfileTab(Map<String, dynamic> emp, String type, String dept, String status) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Header
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  emp['name']?[0] ?? '?',
                  style: TextStyle(
                    fontSize: 40,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emp['name'] ?? 'Unknown',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Chip(label: Text(type), backgroundColor: Colors.blue.withOpacity(0.1)),
                  const SizedBox(width: 8),
                  Chip(label: Text(dept), backgroundColor: Colors.orange.withOpacity(0.1)),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.key),
                label: const Text('Set Login Credentials'),
                onPressed: () => _setCredentials(context, emp['id'], emp['email']),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Secure Info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Identity & Bank Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      icon: Icon(_isPiiRevealed ? Icons.visibility_off : Icons.visibility),
                      label: Text(_isPiiRevealed ? 'Hide' : 'Reveal'),
                      onPressed: () {
                        // In a real app, this would prompt for Owner PIN/Biometrics
                        setState(() {
                          _isPiiRevealed = !_isPiiRevealed;
                        });
                      },
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                _buildInfoRow('Aadhaar Number', _isPiiRevealed ? emp['aadhaar'] ?? '1234 5678 9012' : 'XXXX XXXX ${(emp['aadhaar'] != null && emp['aadhaar'].toString().length >= 4) ? emp['aadhaar'].substring(emp['aadhaar'].length - 4) : '9012'}'),
                const SizedBox(height: 12),
                _buildInfoRow('PAN Number', _isPiiRevealed ? 'ABCDE1234F' : 'XXXXX1234X'),
                const SizedBox(height: 12),
                _buildInfoRow('Phone', _isPiiRevealed ? emp['phone'] ?? 'Unknown' : 'XXXXXX${(emp['phone'] != null && emp['phone'].toString().length >= 4) ? emp['phone'].substring(emp['phone'].length - 4) : 'XXXX'}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

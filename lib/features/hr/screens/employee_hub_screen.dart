import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hr_provider.dart';

class EmployeeHubScreen extends ConsumerStatefulWidget {
  const EmployeeHubScreen({super.key});

  @override
  ConsumerState<EmployeeHubScreen> createState() => _EmployeeHubScreenState();
}

class _EmployeeHubScreenState extends ConsumerState<EmployeeHubScreen> {
  String searchQuery = '';
  String selectedType = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(hrProvider.notifier).fetchEmployees());
  }

  @override
  Widget build(BuildContext context) {
    final hrState = ref.watch(hrProvider);
    final employees = hrState.value?.employees ?? [];

    final filteredEmployees = employees.where((emp) {
      final matchesSearch = emp['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) || 
                            emp['id'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      final matchesType = selectedType == 'All' || emp['type'] == selectedType;
      return matchesSearch && matchesType;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Employee',
            onPressed: () {
              context.goNamed('add_employee');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Actions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAction(context, 'Attendance', Icons.calendar_today, 'attendance_dashboard'),
                  _buildQuickAction(context, 'Self Check-In', Icons.location_on, 'self_checkin'),
                  _buildQuickAction(context, 'Calendar', Icons.event_note, 'attendance_calendar'),
                  _buildQuickAction(context, 'Leave', Icons.time_to_leave, 'leave_application'),
                  _buildQuickAction(context, 'Advances', Icons.account_balance_wallet, 'advance_management'),
                  _buildQuickAction(context, 'Piece Work', Icons.assignment, 'piece_work_entry'),
                  _buildQuickAction(context, 'Piece Log', Icons.list_alt, 'piece_work_log'),
                  _buildQuickAction(context, 'Payroll', Icons.calculate, 'payroll_generation'),
                  _buildQuickAction(context, 'Payslip', Icons.receipt, 'payslip'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Filter & Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name or ID...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: ['All', 'Worker', 'Operator', 'Supervisor'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          selectedType = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Employee List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                final emp = filteredEmployees[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        emp['name'][0],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      emp['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          _buildBadge(emp['type'], Colors.blue),
                          const SizedBox(width: 8),
                          _buildBadge(emp['department'], Colors.orange),
                          const SizedBox(width: 8),
                          _buildBadge(
                            emp['status'], 
                            emp['status'] == 'Active' ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.goNamed('employee_detail', extra: emp);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, String routeName) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        onPressed: () {
          context.goNamed(routeName);
        },
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

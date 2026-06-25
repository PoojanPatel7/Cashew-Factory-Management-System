import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hr_provider.dart';

class AttendanceDashboardPage extends ConsumerStatefulWidget {
  const AttendanceDashboardPage({super.key});

  @override
  ConsumerState<AttendanceDashboardPage> createState() => _AttendanceDashboardPageState();
}

class _AttendanceDashboardPageState extends ConsumerState<AttendanceDashboardPage> {
  DateTime selectedDate = DateTime.now();
  Map<String, String> localStatusMap = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(hrProvider.notifier).fetchEmployees());
  }

  @override
  Widget build(BuildContext context) {
    final hrState = ref.watch(hrProvider);
    final employees = hrState.value?.employees ?? [];

    // Initialize local state for any employee not already in the map
    for (var emp in employees) {
      if (!localStatusMap.containsKey(emp['id'])) {
        localStatusMap[emp['id']] = 'Present'; // default assumption
      }
    }

    int present = localStatusMap.values.where((s) => s == 'Present').length;
    int absent = localStatusMap.values.where((s) => s == 'Absent').length;
    int late = localStatusMap.values.where((s) => s == 'Late').length;
    int total = employees.length > 0 ? employees.length : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
          ),
        ],
      ),
      body: employees.isEmpty 
        ? const Center(child: CircularProgressIndicator())
        : Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard('Present', present, total, Colors.green),
                _buildSummaryCard('Absent', absent, total, Colors.red),
                _buildSummaryCard('Late', late, total, Colors.orange),
              ],
            ),
          ),
          const Divider(),
          // Grid View / List
          Expanded(
            child: ListView.builder(
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final emp = employees[index];
                final String id = emp['id'];
                final String name = emp['name'] ?? 'Unknown';
                final String dept = emp['department'] ?? 'Unknown';
                final String status = localStatusMap[id] ?? 'Present';

                return ListTile(
                  leading: CircleAvatar(child: Text(name[0])),
                  title: Text(name),
                  subtitle: Text(dept),
                  trailing: DropdownButton<String>(
                    value: status,
                    items: ['Present', 'Absent', 'Late', 'Half-Day'].map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          localStatusMap[id] = val;
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // In real app, we would send the whole localStatusMap to backend
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attendance Saved Successfully!')),
          );
        },
        icon: const Icon(Icons.save),
        label: const Text('Save Attendance'),
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, int total, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                value: count / total,
                color: color,
                backgroundColor: color.withOpacity(0.2),
                strokeWidth: 6,
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

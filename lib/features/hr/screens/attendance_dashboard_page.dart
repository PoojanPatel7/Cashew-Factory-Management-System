import 'package:flutter/material.dart';

class AttendanceDashboardPage extends StatefulWidget {
  const AttendanceDashboardPage({super.key});

  @override
  State<AttendanceDashboardPage> createState() => _AttendanceDashboardPageState();
}

class _AttendanceDashboardPageState extends State<AttendanceDashboardPage> {
  DateTime selectedDate = DateTime.now();

  final List<Map<String, dynamic>> employees = [
    {'id': 'E001', 'name': 'Ramesh Kumar', 'dept': 'Shelling', 'status': 'Present'},
    {'id': 'E002', 'name': 'Suresh Singh', 'dept': 'Peeling', 'status': 'Absent'},
    {'id': 'E003', 'name': 'Geeta Devi', 'dept': 'Grading', 'status': 'Late'},
    {'id': 'E004', 'name': 'Amit Patel', 'dept': 'Maintenance', 'status': 'Present'},
  ];

  @override
  Widget build(BuildContext context) {
    int present = employees.where((e) => e['status'] == 'Present').length;
    int absent = employees.where((e) => e['status'] == 'Absent').length;
    int late = employees.where((e) => e['status'] == 'Late').length;

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
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard('Present', present, Colors.green),
                _buildSummaryCard('Absent', absent, Colors.red),
                _buildSummaryCard('Late', late, Colors.orange),
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
                return ListTile(
                  leading: CircleAvatar(child: Text(emp['name'][0])),
                  title: Text(emp['name']),
                  subtitle: Text(emp['dept']),
                  trailing: DropdownButton<String>(
                    value: emp['status'],
                    items: ['Present', 'Absent', 'Late', 'Half-Day'].map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          emp['status'] = val;
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attendance Saved Successfully!')),
          );
        },
        icon: const Icon(Icons.save),
        label: const Text('Save Attendance'),
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                value: count / employees.length,
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

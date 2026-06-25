import 'package:flutter/material.dart';

class PieceWorkDailyLogPage extends StatefulWidget {
  const PieceWorkDailyLogPage({super.key});

  @override
  State<PieceWorkDailyLogPage> createState() => _PieceWorkDailyLogPageState();
}

class _PieceWorkDailyLogPageState extends State<PieceWorkDailyLogPage> {
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _logs = [
    {'id': 'L001', 'empId': 'E001', 'name': 'Ramesh Kumar', 'task': 'Shelling', 'qty': 200, 'rate': 15, 'total': 3000},
    {'id': 'L002', 'empId': 'E003', 'name': 'Geeta Devi', 'task': 'Grading', 'qty': 150, 'rate': 10, 'total': 1500},
  ];

  void _handleDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this entry? This action is for Supervisors only.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _logs.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entry deleted successfully')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalPayout = _logs.fold(0, (sum, log) => sum + (log['total'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Piece-Work Daily Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${_selectedDate.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total payout: ₹$totalPayout',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${log['name']} (${log['empId']})'),
                    subtitle: Text('${log['task']} | Qty: ${log['qty']}kg @ ₹${log['rate']}/kg'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${log['total']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _handleDelete(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

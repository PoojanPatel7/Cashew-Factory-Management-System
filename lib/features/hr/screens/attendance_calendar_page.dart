import 'package:flutter/material.dart';

class AttendanceCalendarPage extends StatelessWidget {
  const AttendanceCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.chevron_left),
                      Text('June 2026', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: 30, // Days in June
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      Color statusColor;
                      if (day % 7 == 0) {
                        statusColor = Colors.grey; // Sunday / Off
                      } else if (day % 5 == 0) {
                        statusColor = Colors.red; // Absent
                      } else if (day % 8 == 0) {
                        statusColor = Colors.orange; // Half-Day / Late
                      } else {
                        statusColor = Colors.green; // Present
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: statusColor, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            day.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Summary
            const Text('Monthly Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryStat('Present', '22', Colors.green),
                _buildSummaryStat('Absent', '3', Colors.red),
                _buildSummaryStat('Half-Day', '1', Colors.orange),
                _buildSummaryStat('Off', '4', Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

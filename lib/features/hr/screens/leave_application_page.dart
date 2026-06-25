import 'package:flutter/material.dart';

class LeaveApplicationPage extends StatefulWidget {
  const LeaveApplicationPage({super.key});

  @override
  State<LeaveApplicationPage> createState() => _LeaveApplicationPageState();
}

class _LeaveApplicationPageState extends State<LeaveApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  String _leaveType = 'Casual Leave';
  String _reason = '';
  DateTimeRange? _dateRange;

  void _handleSubmit() {
    if (!_formKey.currentState!.validate() || _dateRange == null) {
      if (_dateRange == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select date range')));
      }
      return;
    }
    _formKey.currentState!.save();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Leave Application'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: $_leaveType'),
              Text('From: ${_dateRange!.start.toString().split(' ')[0]}'),
              Text('To: ${_dateRange!.end.toString().split(' ')[0]}'),
              Text('Duration: ${_dateRange!.end.difference(_dateRange!.start).inDays + 1} Days'),
              const SizedBox(height: 8),
              Text('Reason: $_reason', style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Leave Application Submitted for Approval')),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Leave')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<String>(
              value: _leaveType,
              decoration: const InputDecoration(
                labelText: 'Leave Type',
                border: OutlineInputBorder(),
              ),
              items: ['Casual Leave', 'Sick Leave', 'Earned Leave'].map((t) {
                return DropdownMenuItem(value: t, child: Text(t));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _leaveType = val);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(color: Colors.grey),
              ),
              title: Text(_dateRange == null 
                ? 'Select Date Range' 
                : '${_dateRange!.start.toString().split(' ')[0]} to ${_dateRange!.end.toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _dateRange = picked);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reason for Leave',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (val) => val == null || val.isEmpty ? 'Please provide a reason' : null,
              onSaved: (val) => _reason = val ?? '',
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _handleSubmit,
              icon: const Icon(Icons.send),
              label: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Submit Application', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelfCheckinPage extends StatefulWidget {
  const SelfCheckinPage({super.key});

  @override
  State<SelfCheckinPage> createState() => _SelfCheckinPageState();
}

class _SelfCheckinPageState extends State<SelfCheckinPage> {
  bool isCheckedIn = false;
  DateTime? checkInTime;

  void _handleCheckIn() {
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm a').format(now);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Check-In'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 48, color: Colors.blue),
              const SizedBox(height: 16),
              Text('Check in at $timeStr?', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Location: Factory Floor A (Verified)'),
              const SizedBox(height: 16),
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Icon(Icons.camera_alt, size: 48, color: Colors.grey)),
              ),
              const SizedBox(height: 8),
              const Text('Selfie captured for verification', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isCheckedIn = true;
                  checkInTime = now;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully Checked In')),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _handleCheckOut() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Check-Out'),
          content: const Text('Are you sure you want to check out for the day?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isCheckedIn = false;
                  checkInTime = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully Checked Out')),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Self Check-In')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('h:mm a').format(DateTime.now()),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              
              if (isCheckedIn) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Checked In at ${DateFormat('h:mm a').format(checkInTime!)}',
                  style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _handleCheckOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Check Out', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ] else ...[
                const Icon(Icons.location_searching, color: Colors.blue, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Ready to Check In',
                  style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _handleCheckIn,
                    icon: const Icon(Icons.login),
                    label: const Text('Check In Now', style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

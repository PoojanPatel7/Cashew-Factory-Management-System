import 'package:flutter/material.dart';

class DispatchTrackingPage extends StatelessWidget {
  const DispatchTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispatch Tracking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DSP-23-102', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Order: ORD-2023-005'),
                  Text('Customer: Premium Nuts Traders'),
                  Text('Vehicle: MH-04-AB-1234'),
                  Text('Driver: Ramesh Kumar (+91 9876543211)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Tracking Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTimelineNode('Packed & Ready', '15-Jun 02:00 PM', isCompleted: true),
          _buildTimelineNode('Dispatched from Factory', '15-Jun 03:30 PM', isCompleted: true),
          _buildTimelineNode('In Transit', 'Current Status', isCompleted: true),
          _buildTimelineNode('Delivered', 'Pending Delivery Proof', isCompleted: false, isLast: true),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: () {
                _showDeliveryProofDialog(context);
              },
              icon: const Icon(Icons.verified),
              label: const Text('Mark as Delivered (POD)'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(String title, String time, {bool isCompleted = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, color: isCompleted ? Colors.blue : Colors.grey, size: 24),
            if (!isLast)
              Container(width: 2, height: 40, color: isCompleted ? Colors.blue : Colors.grey),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
            Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  void _showDeliveryProofDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Proof of Delivery (POD)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt), label: const Text('Take Photo of Signed Challan')),
            const SizedBox(height: 16),
            const Text('OR'),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.draw), label: const Text('Collect E-Signature')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery confirmed!')));
          }, child: const Text('Submit')),
        ],
      ),
    );
  }
}

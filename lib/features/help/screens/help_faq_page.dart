import 'package:flutter/material.dart';

class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Search FAQs...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Frequently Asked Questions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          const ExpansionTile(
            title: Text('How do I add a new machine?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Go to Machinery > Machine Registry > click the Add (+) button. Fill out the specs and save to generate the QR code.'),
              ),
            ],
          ),
          const ExpansionTile(
            title: Text('How do I approve an expense?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Navigate to the Accounting dashboard or Notification center and look for Pending Approvals. Tap the item and click Approve.'),
              ),
            ],
          ),
          const ExpansionTile(
            title: Text('Why is my inventory showing negative?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('This happens if dispatch is logged before the corresponding lot output is finalized. Do a stock adjustment to correct it.'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Contact Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Email Support'),
              subtitle: const Text('support@cashewpro.app'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Call Helpline'),
              subtitle: const Text('+91 1800-CASHEW-PRO'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text('CashewPro ERP v0.11.0\n© 2026 Poojan Patel', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PayslipPage extends StatelessWidget {
  const PayslipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payslip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share PDF',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing Payslip PDF...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download PDF',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading Payslip PDF...')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CASHEWPRO FACTORY', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const Text('Industrial Area, Kerala, India'),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('PAYSLIP', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Divider(height: 32, thickness: 2),

                // Employee Info
                const Text('Payslip for the month of: June 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: Ramesh Kumar', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Employee ID: E001'),
                        Text('Department: Shelling'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Bank: SBI (XXXX3210)'),
                        Text('UAN: 100XXXXX345'),
                        Text('PAN: XXXX1234X'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Earnings & Deductions Table
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: const [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.black12),
                      children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Earnings', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Amount (₹)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Deductions', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Amount (₹)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Basic Pay')),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('12,000.00', textAlign: TextAlign.right)),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('PF')),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('1,440.00', textAlign: TextAlign.right)),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Piece-Work')),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('4,500.00', textAlign: TextAlign.right)),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Advance EMI')),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('2,000.00', textAlign: TextAlign.right)),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Overtime')),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('500.00', textAlign: TextAlign.right)),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('ESI')),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('130.00', textAlign: TextAlign.right)),
                      ],
                    ),
                    TableRow(
                      decoration: BoxDecoration(color: Colors.black12),
                      children: [
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Gross Earnings', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('17,000.00', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('Total Deductions', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8.0), child: Text('3,570.00', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Net Pay
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green.withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('NET PAY', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      const Text('₹13,430.00', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Amount in words: Thirteen Thousand Four Hundred Thirty Rupees Only.', style: TextStyle(fontStyle: FontStyle.italic)),
                
                const SizedBox(height: 64),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Employer Signature\n________________', textAlign: TextAlign.center),
                    Text('Employee Signature\n________________', textAlign: TextAlign.center),
                  ],
                ),
                const SizedBox(height: 32),
                const Center(child: Text('This is a system generated payslip.', style: TextStyle(fontSize: 10, color: Colors.grey))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

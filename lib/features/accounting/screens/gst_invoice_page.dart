import 'package:flutter/material.dart';

class GstInvoicePage extends StatelessWidget {
  const GstInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Invoice Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading GST Invoice PDF...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('CashewPro Factory', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('123 Cashew Estate, Goa, 403001', style: TextStyle(color: Colors.black87)),
                        Text('GSTIN: 30ABCDE1234F1Z5', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text('TAX INVOICE', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Inv No: INV-2324-0042', style: TextStyle(color: Colors.black87)),
                        Text('Date: 15-Jun-2023', style: TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.black26, height: 32),
                const Text('Bill To:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                const Text('Premium Nuts Traders', style: TextStyle(color: Colors.black87)),
                const Text('Mumbai, Maharashtra', style: TextStyle(color: Colors.black87)),
                const Text('GSTIN: 27XYZAB5678C1Z2', style: TextStyle(color: Colors.black87)),
                const SizedBox(height: 24),
                Table(
                  border: TableBorder.all(color: Colors.black26),
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(1.5),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Colors.black12),
                      children: [
                        Padding(padding: EdgeInsets.all(8), child: Text('Item Description', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('HSN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Qty(kg)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Rate', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Amount', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const TableRow(
                      children: [
                        Padding(padding: EdgeInsets.all(8), child: Text('W320 Premium Cashew', style: TextStyle(color: Colors.black))),
                        Padding(padding: EdgeInsets.all(8), child: Text('08013200', style: TextStyle(color: Colors.black))),
                        Padding(padding: EdgeInsets.all(8), child: Text('100', style: TextStyle(color: Colors.black))),
                        Padding(padding: EdgeInsets.all(8), child: Text('750', style: TextStyle(color: Colors.black))),
                        Padding(padding: EdgeInsets.all(8), child: Text('75,000.00', style: TextStyle(color: Colors.black))),
                      ],
                    ),
                    const TableRow(
                      children: [
                        Padding(padding: EdgeInsets.all(8), child: Text('W240 Jumbo Cashew', style: TextStyle(color: Colors.black))),
                        Padding(padding: EdgeInsets.all(8), child: Text('08013200', style: TextStyle(color: Colors.black))),
                        Padding(padding: EdgeInsets.all(8), child: Text('50', style: TextStyle(color: Colors.black))),
                        Padding(padding: EdgeInsets.all(8), child: Text('850', style: TextStyle(color: Colors.black))),
                        Padding(padding: EdgeInsets.all(8), child: Text('42,500.00', style: TextStyle(color: Colors.black))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text('Taxable Amount:', style: TextStyle(color: Colors.black87)),
                        Text('IGST (5%):', style: TextStyle(color: Colors.black87)),
                        SizedBox(height: 8),
                        Text('Total Invoice Value:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text('₹ 1,17,500.00', style: TextStyle(color: Colors.black87)),
                        Text('₹ 5,875.00', style: TextStyle(color: Colors.black87)),
                        SizedBox(height: 8),
                        Text('₹ 1,23,375.00', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('Amount in words:', style: TextStyle(color: Colors.black87)),
                const Text('Rupees One Lakh Twenty Three Thousand Three Hundred Seventy Five Only.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 48),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('Authorized Signatory', style: TextStyle(color: Colors.black87)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

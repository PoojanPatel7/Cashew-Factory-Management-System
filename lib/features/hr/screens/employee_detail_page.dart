import 'package:flutter/material.dart';

class EmployeeDetailPage extends StatefulWidget {
  final Map<String, dynamic>? employee;
  
  const EmployeeDetailPage({super.key, this.employee});

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPiiRevealed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final emp = widget.employee ?? {};
    final String name = emp['name'] ?? 'Unknown';
    final String type = emp['type'] ?? 'Unknown';
    final String dept = emp['department'] ?? 'Unknown';
    final String status = emp['status'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Attendance'),
            Tab(text: 'Earnings'),
            Tab(text: 'Payslips'),
            Tab(text: 'Advances'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(emp, type, dept, status),
          const Center(child: Text('Attendance Data')),
          const Center(child: Text('Earnings Data')),
          const Center(child: Text('Payslips Data')),
          const Center(child: Text('Advances Data')),
        ],
      ),
    );
  }

  Widget _buildProfileTab(Map<String, dynamic> emp, String type, String dept, String status) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Header
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  emp['name']?[0] ?? '?',
                  style: TextStyle(
                    fontSize: 40,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emp['name'] ?? 'Unknown',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Chip(label: Text(type), backgroundColor: Colors.blue.withOpacity(0.1)),
                  const SizedBox(width: 8),
                  Chip(label: Text(dept), backgroundColor: Colors.orange.withOpacity(0.1)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Secure Info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Identity & Bank Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      icon: Icon(_isPiiRevealed ? Icons.visibility_off : Icons.visibility),
                      label: Text(_isPiiRevealed ? 'Hide' : 'Reveal'),
                      onPressed: () {
                        // In a real app, this would prompt for Owner PIN/Biometrics
                        setState(() {
                          _isPiiRevealed = !_isPiiRevealed;
                        });
                      },
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                _buildInfoRow('Aadhaar Number', _isPiiRevealed ? '1234 5678 9012' : 'XXXX XXXX 9012'),
                const SizedBox(height: 12),
                _buildInfoRow('PAN Number', _isPiiRevealed ? 'ABCDE1234F' : 'XXXXX1234X'),
                const SizedBox(height: 12),
                _buildInfoRow('Bank A/C', _isPiiRevealed ? '9876543210' : 'XXXXXX3210'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class ReportViewerPage extends StatelessWidget {
  final String reportName;

  const ReportViewerPage({super.key, required this.reportName});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(reportName),
        actions: [
          IconButton(icon: const Icon(Icons.star_border), onPressed: () {}, tooltip: 'Add to Favorites'),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}, tooltip: 'Share'),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Date Range',
                      prefixIcon: Icon(Icons.date_range),
                      filled: true,
                    ),
                    readOnly: true,
                    controller: TextEditingController(text: '01-Jun-2026 to 25-Jun-2026'),
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.refresh), label: const Text('Generate')),
              ],
            ),
          ),
          
          Expanded(
            child: isWide
                ? Row(
                    children: [
                      Expanded(child: _buildChartSection(context)),
                      Expanded(child: _buildTableSection(context)),
                    ],
                  )
                : ListView(
                    children: [
                      _buildChartSection(context),
                      _buildTableSection(context),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(onPressed: () {}, icon: const Icon(Icons.print), label: const Text('Print')),
            const SizedBox(width: 16),
            FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.table_chart), label: const Text('Export Excel')),
            const SizedBox(width: 16),
            FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf), label: const Text('Export PDF')),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Dynamic Data Visualization Placeholder', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Metric A')),
            DataColumn(label: Text('Metric B')),
            DataColumn(label: Text('Total')),
          ],
          rows: List.generate(
            5,
            (index) => DataRow(cells: [
              DataCell(Text('2026-06-0${index + 1}')),
              DataCell(Text('${(index + 1) * 100}')),
              DataCell(Text('${(index + 1) * 50}')),
              DataCell(Text('${(index + 1) * 150}')),
            ]),
          ),
        ),
      ),
    );
  }
}

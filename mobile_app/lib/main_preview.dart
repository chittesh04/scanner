import 'package:flutter/material.dart';

void main() {
  runApp(const SmartScanPreviewApp());
}

class SmartScanPreviewApp extends StatelessWidget {
  const SmartScanPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartScan Preview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const _PreviewPage(),
    );
  }
}

class _PreviewPage extends StatelessWidget {
  const _PreviewPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartScan')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('Invoice - March'),
            subtitle: Text('3 page(s)'),
          ),
          ListTile(
            leading: Icon(Icons.receipt_long_outlined),
            title: Text('Receipts Bundle'),
            subtitle: Text('7 page(s)'),
          ),
          ListTile(
            leading: Icon(Icons.assignment_outlined),
            title: Text('ID Proof Scan'),
            subtitle: Text('1 page(s)'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Scan'),
      ),
    );
  }
}

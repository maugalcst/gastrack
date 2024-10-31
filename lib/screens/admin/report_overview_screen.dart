import 'package:flutter/material.dart';

class ReportOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes'),
        backgroundColor: Color(0xFF07154C),
      ),
      body: Center(
        child: Text(
          'Vista de Reportes (placeholder)',
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
      ),
    );
  }
}

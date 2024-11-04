// lib/screens/admin/performance_screen.dart
import 'package:flutter/material.dart';

class PerformanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rendimiento'),
        backgroundColor: Color(0xFF07154C),
      ),
      body: Center(
        child: Text(
          'Vista de Rendimiento (placeholder)',
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
      ),
    );
  }
}

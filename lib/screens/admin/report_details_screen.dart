import 'package:flutter/material.dart';

class ReportDetailsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> employeeReports;
  final String employeeName;
  final String employeeEmail;

  ReportDetailsScreen({
    required this.employeeReports,
    required this.employeeName,
    required this.employeeEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF07154C),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Center(
              child: Text(
                'GasTrack',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFFF7D21),
                  decorationThickness: 2,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: employeeReports.length,
        itemBuilder: (context, index) {
          final report = employeeReports[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalles del Reporte ${index + 1}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF07154C),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildDetailRow('Fecha', report['date'] ?? 'Sin fecha'),
                  _buildDetailRow('Empleado', employeeName),
                  _buildDetailRow('Email del Empleado', employeeEmail),
                  _buildDetailRow('Unidad', report['unit_number'] ?? 'Sin número'),
                  _buildDetailRow('Litros de Gasolina', '${report['gasoline_liters'] ?? 0} L'),
                  _buildDetailRow('Odómetro', '${report['odometer_reading'] ?? 0} km'),
                  SizedBox(height: 16),
                  Text(
                    'Imágenes del Reporte',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF07154C),
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildImageSection('Ticket de Gasolina', report['gasoline_receipt_image_url']),
                  _buildImageSection('Odómetro', report['odometer_image_url']),
                  SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Función para mostrar los detalles en formato de fila
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF07154C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF07154C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función para mostrar imágenes con el título
  Widget _buildImageSection(String title, String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF07154C),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        imageUrl != null
            ? Image.network(imageUrl)
            : Text(
                'Imagen no disponible',
                style: TextStyle(color: Colors.grey),
              ),
      ],
    );
  }
}

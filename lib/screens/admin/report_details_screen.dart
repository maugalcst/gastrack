import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReportDetailsScreen extends StatefulWidget {
  final String employeeEmail;

  ReportDetailsScreen({required this.employeeEmail});

  @override
  _ReportDetailsScreenState createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  List<Map<String, dynamic>> employeeReports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmployeeReports();
  }

  Future<void> _fetchEmployeeReports() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('email', isEqualTo: widget.employeeEmail)
          .orderBy('date', descending: true)
          .get();

      setState(() {
        employeeReports = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error al obtener los reportes del empleado: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Detalles del Reporte',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Fecha: ${DateFormat('dd/MM/yy').format(report['date'].toDate())}'),
                Text('Unidad: ${report['unit_number']}'),
                Text('Kilometraje: ${report['odometer_reading']} km'),
                Text('Litros de Gasolina: ${report['gasoline_liters']} L'),
                SizedBox(height: 10),
                Text('Ticket de Gasolina:'),
                report['gasoline_receipt_image_url'] != null
                    ? Image.network(report['gasoline_receipt_image_url'])
                    : Text('No disponible'),
                SizedBox(height: 10),
                Text('Odómetro:'),
                report['odometer_image_url'] != null
                    ? Image.network(report['odometer_image_url'])
                    : Text('No disponible'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cerrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : employeeReports.isEmpty
              ? Center(child: Text('No hay reportes para este empleado.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: employeeReports.length,
                  itemBuilder: (context, index) {
                    final report = employeeReports[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(report['date'].toDate()),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF07154C),
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _showReportDetails(context, report);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF07154C),
                                  ),
                                  child: Text(
                                    'Ver reporte',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.download, color: Color(0xFF07154C)),
                                  onPressed: () {
                                    // Acción para descargar reporte
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

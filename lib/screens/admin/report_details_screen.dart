import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      print('Fetching reports for employee email: ${widget.employeeEmail}');
      
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('email', isEqualTo: widget.employeeEmail)
          .orderBy('date', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No reports found for the specified email.');
      } else {
        print('Reports found: ${snapshot.docs.length}');
      }

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha: ${report['date'].toDate().toLocal()}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF07154C),
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildDetailRow('Unidad', report['unit_number'] ?? 'Sin número'),
                            _buildDetailRow('Litros de Gasolina', '${report['gasoline_liters'] ?? 0} L'),
                            _buildDetailRow('Odómetro', '${report['odometer_reading'] ?? 0} km'),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Acción para ver detalles del reporte
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF07154C),
                                    ),
                                    child: Text('Ver reporte'),
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
}

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

  final Color backgroundColor = Color.fromARGB(255, 232, 236, 255); // Fondo con color claro degradado
  final Color darkBlueColor = Color(0xFF07154C); // Azul oscuro para el texto y los botones

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
          backgroundColor: darkBlueColor,
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
      body: Stack(
        children: [
          // Fondo con degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 209, 217, 255),
                  Colors.white,
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y descripción
                  Text(
                    'Reportes',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: darkBlueColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aquí puede observar y descargar los reportes que se han registrado así como historial de reportes de los usuarios.',
                    style: TextStyle(
                      fontSize: 19,
                      color: darkBlueColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.employeeEmail,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: darkBlueColor,
                    ),
                  ),
                  SizedBox(height: 24), // Espacio adicional entre la descripción y los reportes
                  // Lista de reportes
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : employeeReports.isEmpty
                          ? Center(child: Text('No hay reportes para este empleado.'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(0),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: employeeReports.length,
                              itemBuilder: (context, index) {
                                final report = employeeReports[index];
                                String formattedDate = DateFormat('dd/MM/yyyy').format(report['date'].toDate());

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Card(
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    elevation: 0.5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Fecha del reporte
                                          Text(
                                            formattedDate,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: darkBlueColor,
                                            ),
                                          ),
                                          // Botones de acciones
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  _showReportDetails(context, report);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color.fromARGB(255, 18, 90, 207),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                ),
                                                child: Text(
                                                  'Ver reporte',
                                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Container(
                                                width: 53,
                                                height: 45,
                                                decoration: BoxDecoration(
                                                  color: darkBlueColor,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.download, color: Colors.white),
                                                  onPressed: () {
                                                    // Acción para descargar el reporte
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                Text('Fecha: ${DateFormat('dd/MM/yyyy').format(report['date'].toDate())}'),
                Text('Unidad: ${report['unit_number']}'),
                Text('Kilometraje: ${report['odometer_reading']}'),
                Text('Litros de Gasolina: ${report['gasoline_liters']}'),
                SizedBox(height: 10),
                Text('Ticket de Gasolina:'),
                Image.network(report['gasoline_receipt_image_url']),
                SizedBox(height: 10),
                Text('Odómetro:'),
                Image.network(report['odometer_image_url']),
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
}

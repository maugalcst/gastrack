import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class ReportDetailsScreen extends StatefulWidget {
  final String employeeEmail;

  ReportDetailsScreen({required this.employeeEmail});

  @override
  _ReportDetailsScreenState createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  List<Map<String, dynamic>> employeeReports = [];
  bool isLoading = true;

  final Color backgroundColor = Color.fromARGB(255, 232, 236, 255);
  final Color darkBlueColor = Color(0xFF07154C);

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

  bool isDownloading = false; // Controla el estado de descarga

Future<void> _downloadExcel(Map<String, dynamic> report) async {
  setState(() {
    isDownloading = true; // Inicia el estado de descarga
  });

  // Mostrar un SnackBar indicando que la descarga ha comenzado
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Descargando reporte, espere un momento..."),
      duration: Duration(seconds: 2),
    ),
  );

  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;

  var status = await (Platform.isAndroid && androidInfo.version.sdkInt >= 30
      ? Permission.manageExternalStorage.request()
      : Permission.storage.request());

  if (status.isGranted) {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    
    // Estructura y estilo de Excel
    sheet.getRangeByName('A1:D1').columnWidth = 25;
    sheet.getRangeByName('A1').setText('Reporte de Gasolina');
    sheet.getRangeByName('A1').cellStyle.fontSize = 16;
    sheet.getRangeByName('A1').cellStyle.bold = true;

    sheet.getRangeByName('A3').setText('Fecha:');
    sheet.getRangeByName('B3').setText(DateFormat('dd/MM/yyyy').format(report['date'].toDate()));
    sheet.getRangeByName('A4').setText('Unidad:');
    sheet.getRangeByName('B4').setText(report['unit_number']);
    sheet.getRangeByName('A5').setText('Kilometraje:');
    sheet.getRangeByName('B5').setNumber((report['odometer_reading'] as num).toDouble());
    sheet.getRangeByName('A6').setText('Litros de Gasolina:');
    sheet.getRangeByName('B6').setNumber((report['gasoline_liters'] as num).toDouble());

    // Insertar imágenes
    final Uint8List? ticketImage = await _downloadImage(report['gasoline_receipt_image_url']);
    if (ticketImage != null) {
      sheet.getRangeByName('A8').setText('Ticket de Gasolina:');
      var ticketPicture = sheet.pictures.addStream(8, 2, ticketImage);
      ticketPicture.width = 150;
      ticketPicture.height = 100;
    }

    final Uint8List? odometerImage = await _downloadImage(report['odometer_image_url']);
    if (odometerImage != null) {
      sheet.getRangeByName('A12').setText('Odómetro:');
      var odometerPicture = sheet.pictures.addStream(12, 2, odometerImage);
      odometerPicture.width = 150;
      odometerPicture.height = 100;
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = Directory('/storage/emulated/0/Download');
    final path = "${directory.path}/reporte_${DateFormat('ddMMyyyy').format(report['date'].toDate())}.xlsx";
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Reporte descargado en formato Excel en la carpeta Descargas"),
        duration: Duration(seconds: 3),
      ),
    );

    print("Archivo Excel guardado en $path");
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Permiso de almacenamiento denegado")),
    );
  }

  setState(() {
    isDownloading = false; // Finaliza el estado de descarga
  });
}


Future<Uint8List?> _downloadImage(String url) async {
  try {
    final response = await HttpClient().getUrl(Uri.parse(url));
    final HttpClientResponse res = await response.close();
    if (res.statusCode == 200) {
      return await consolidateHttpClientResponseBytes(res);
    }
  } catch (e) {
    print("Error al descargar la imagen: $e");
  }
  return null;
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  backgroundColor,
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
                  SizedBox(height: 24),
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
                                    color: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            formattedDate,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: darkBlueColor,
                                            ),
                                          ),
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
                                                width: 48,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: darkBlueColor,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.download, color: Colors.white),
                                                  splashColor: Colors.blueAccent.withOpacity(0.3), // Color al hacer clic
                                                  highlightColor: Colors.blueAccent.withOpacity(0.2), // Color al mantener presionado
                                                  onPressed: () async {
                                                    // Mostrar el SnackBar antes de iniciar la descarga
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text("Descargando reporte, espere un momento..."),
                                                        duration: Duration(seconds: 2),
                                                      ),
                                                    );
                                                    await _downloadExcel(report);
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

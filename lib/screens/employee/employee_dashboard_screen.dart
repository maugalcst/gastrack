import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrack_uanl/screens/employee/fuel_report_form_screen.dart';
import 'package:intl/intl.dart'; // Para dar formato a la fecha

class EmployeeDashboardScreen extends StatefulWidget {
  @override
  _EmployeeDashboardScreenState createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // Ajuste de altura de la barra superior
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF07154C),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0), // Espacio superior para ajustar el logo
            child: Center(
              child: Text(
                'GasTrack',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.orange,
                  decorationThickness: 2,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido, Mauricio',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF07154C),
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFDCE6F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF07154C)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recuerda que para el registro es necesario tener ticket de gasolinera a la mano, así como mostrar el odómetro de la unidad.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF07154C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Botón de "Registrar reporte" más grande con gradiente
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FuelReportFormScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(double.infinity, 50), // Para que ocupe todo el ancho
                ).copyWith(
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color.fromARGB(255, 9, 28, 101), Color.fromARGB(255, 152, 67, 7)], // Azul a Naranja
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Registrar reporte',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color(0xFFF0F0F0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Observa tu rendimiento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF07154C),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Rendimiento general',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    Spacer(),
                    Text(
                      '82.5', // Placeholder
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showInfoDialog(context);
                      },
                      icon: Icon(Icons.info_outline),
                      tooltip: 'Ver detalles del rendimiento',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Últimos reportes registrados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF07154C),
                ),
              ),
              SizedBox(height: 8),
              // Muestra los últimos 3 reportes ordenados por fecha
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('reports')
                    .orderBy('date', descending: true) // Orden por fecha descendente
                    .limit(3) // Limitar a los últimos 3 reportes
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('No hay reportes registrados.');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var report = snapshot.data!.docs[index];
                      var reportData = report.data() as Map<String, dynamic>;
                      var date = (reportData['date'] as Timestamp).toDate();
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(Icons.event_note),
                          title: Text('Fecha: ${DateFormat('dd/MM/yy').format(date)}'),
                          subtitle: Text('Unidad: ${reportData['unit_number']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_red_eye),
                            onPressed: () {
                              _showReportDetails(context, reportData);
                            },
                            tooltip: 'Ver reporte',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllReportsScreen()),
                  );
                },
                child: Text('Ver todos mis reportes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF07154C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
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
                Text('Fecha: ${DateFormat('dd/MM/yy').format(report['date'].toDate())}'),
                Text('Unidad: ${report['unit_number']}'),
                Text('Kilometraje: ${report['odometer_reading']}'),
                Text('Litros de Gasolina: ${report['gasoline_liters']}'),
                SizedBox(height: 10),
                // Mostrar la imagen del ticket de gasolina
                Text('Ticket de Gasolina:'),
                Image.network(report['gasoline_receipt_image_url']),
                SizedBox(height: 10),
                // Mostrar la imagen del odómetro
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

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aquí usted registrará el rendimiento diario de su unidad, este rendimiento se calcula usando el kilometraje, litros de gasolina, etc.',
                style: TextStyle(fontSize: 16, color: Color(0xFF07154C)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close, color: Colors.grey),
                tooltip: 'Cerrar',
              ),
            ],
          ),
        );
      },
    );
  }
}

// Pantalla para ver todos los reportes con filtros
class AllReportsScreen extends StatefulWidget {
  @override
  _AllReportsScreenState createState() => _AllReportsScreenState();
}

class _AllReportsScreenState extends State<AllReportsScreen> {
  String _selectedOrder = 'Fecha';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos los reportes'),
        backgroundColor: Color(0xFF07154C),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: _selectedOrder,
            onChanged: (String? newValue) {
              setState(() {
                _selectedOrder = newValue!;
              });
            },
            items: <String>['Fecha', 'Unidad'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .orderBy(_selectedOrder == 'Fecha' ? 'date' : 'unit_number', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No hay reportes registrados.');
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var report = snapshot.data!.docs[index];
                    var reportData = report.data() as Map<String, dynamic>;
                    var date = (reportData['date'] as Timestamp).toDate();
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(Icons.event_note),
                        title: Text('Fecha: ${DateFormat('dd/MM/yy').format(date)}'),
                        subtitle: Text('Unidad: ${reportData['unit_number']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          onPressed: () {
                            _showReportDetails(context, reportData);
                          },
                          tooltip: 'Ver reporte',
                        ),
                      ),
                    );
                  },
                );
              },
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
        var date = (report['date'] as Timestamp).toDate();
        return AlertDialog(
          title: Text('Detalles del Reporte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha: ${DateFormat('dd/MM/yy').format(date)}'),
              Text('Unidad: ${report['unit_number']}'),
              Text('Kilometraje: ${report['odometer_reading']}'),
              Text('Litros de Gasolina: ${report['gasoline_liters']}'),
              SizedBox(height: 10),
              Text('Ticket de Gasolina:'),
              Image.network(report['gasoline_receipt_image_url']),
              SizedBox(height: 10),
              Text('Odómetro:'),
              Image.network(report['odometer_image_url']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}

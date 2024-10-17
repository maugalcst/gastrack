import 'package:flutter/material.dart';
import 'package:gastrack_uanl/screens/employee/fuel_report_form_screen.dart';

class EmployeeDashboardScreen extends StatelessWidget {
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
                  // Estilo para simular el delineado
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
                  color: Color(0xFF07154C), // Color reemplazado
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
                    Icon(Icons.info_outline, color: Color(0xFF07154C)), // Color reemplazado
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recuerda que para el registro es necesario tener ticket de gasolinera a la mano, así como mostrar el odómetro de la unidad.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF07154C), // Color reemplazado
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FuelReportFormScreen()),
                  );
                },
                icon: Icon(Icons.assignment_outlined),
                label: Text('Registrar reporte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF07154C), // Color reemplazado
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  textStyle: TextStyle(fontSize: 16),
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
                            color: Color(0xFF07154C), // Color reemplazado
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
                      '82.5',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Mostrar pestaña emergente con información adicional
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
                  color: Color(0xFF07154C), // Color reemplazado
                ),
              ),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(Icons.event_note),
                      title: Text('Fecha: 21/09/24'),
                      subtitle: Text('Unidad: N51'),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: Text('Ver todos mis reportes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF07154C), // Color reemplazado
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

  // Método para mostrar la pestaña emergente
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
                'Aquí usted registrará el rendimiento diario de su unidad, este rendimiento se calcula usando el kilometraje, litros de gasolina, etc. Se creará un reporte con los datos que ingrese y se calculará el rendimiento.',
                style: TextStyle(fontSize: 16, color: Color(0xFF07154C)), // Color reemplazado
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar la ventana
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

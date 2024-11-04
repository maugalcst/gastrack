import 'package:flutter/material.dart';
import 'package:gastrack_uanl/screens/admin/report_overview_screen.dart';
import 'package:gastrack_uanl/screens/admin/performance_screen.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatelessWidget {
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
                  decorationColor: Color(0xFFFF7D21), // Naranja
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
                  Color.fromARGB(255, 209, 217, 255), // Azul tenue superior
                  Colors.white, // Blanco inferior
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
                  // Panel de rendimiento general
                  Text(
                    'Panel de \nAdministrador',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF07154C),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Observa el rendimiento general e individual de las unidades, así como los reportes generados e historiales, así como detalles analíticos.',
                    style: TextStyle(
                      fontSize: 19,
                      color: Color(0xFF07154C),
                    ),
                  ),
                  SizedBox(height: 24), // Más espacio entre elementos
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '82.5', // Este valor cambiará dinámicamente
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 8), // Espacio entre el número y el icono
                        IconButton(
                          onPressed: () {
                            _showInfoDialog(context);
                          },
                          icon: Icon(Icons.info_outline),
                          tooltip: 'Información sobre rendimiento',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Detalles del rendimiento
                  Text(
                    'Detalles',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF07154C),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildDetailCard('Total de unidades', '6'),
                  _buildDetailCard('Kilometraje total', '45,000'),
                  _buildDetailCard('Litros consumidos', '3,500'),
                  _buildDetailCard('Costo total', '75,000'),
                ],
              ),
            ),
          ),
          // Botón de menú en la esquina superior derecha debajo de la barra azul
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.menu, color: Color(0xFF07154C), size: 28),
              onPressed: () {
                _showMenu(context);
              },
            ),
          ),
        ],
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
                'Este rendimiento se calcula usando el kilometraje, litros de gasolina, etc. Se creará un reporte con los datos que ingrese el empleado y se calculará el rendimiento.',
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

  // Widget para los detalles en forma de tarjeta
  Widget _buildDetailCard(String label, String value) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF07154C),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF07154C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para mostrar el menú lateral
  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMenuItem(context, 'Panel principal', Icons.home, () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
                );
              }),
              _buildMenuItem(context, 'Rendimiento', Icons.show_chart, () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PerformanceScreen()),
                );
              }),
              _buildMenuItem(context, 'Reportes', Icons.receipt_long, () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportOverviewScreen()),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // Widget para construir cada item del menú
  Widget _buildMenuItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF07154C)),
      title: Text(title, style: TextStyle(color: Color(0xFF07154C))),
      onTap: onTap,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastrack_uanl/screens/admin/report_overview_screen.dart';
import 'package:gastrack_uanl/screens/admin/performance_screen.dart';
import 'package:intl/intl.dart';
import 'package:gastrack_uanl/screens/login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {

  Future<double> calculateGeneralAveragePerformance() async {
  try {
    // Obtener la colección de empleados
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .get();

    // Acumular el rendimiento de cada empleado
    double totalPerformance = 0.0;
    int employeeCount = 0;

    for (var userDoc in usersSnapshot.docs) {
      String email = userDoc['email'];

      // Obtener los últimos 3 reportes de cada empleado
      QuerySnapshot reportsSnapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('email', isEqualTo: email)
          .orderBy('date', descending: true)
          .limit(3)
          .get();

      // Calcular el rendimiento individual
      if (reportsSnapshot.docs.length > 1) {
        double totalKm = 0;
        double totalLiters = 0;
        int? lastOdometer;

        for (var reportDoc in reportsSnapshot.docs.reversed) {
          var data = reportDoc.data() as Map<String, dynamic>;
          int odometerReading = data['odometer_reading'] ?? 0;
          int gasolineLiters = data['gasoline_liters'] ?? 0;

          if (lastOdometer != null && odometerReading > lastOdometer) {
            totalKm += (odometerReading - lastOdometer);
            totalLiters += gasolineLiters;
          } else if (lastOdometer == null) {
            lastOdometer = odometerReading;
          }

          lastOdometer = odometerReading;
        }

        double performance = (totalLiters > 0) ? totalKm / totalLiters : 0.0;
        totalPerformance += performance;
        employeeCount++;
      }
    }

    // Calcular el promedio general
    return (employeeCount > 0) ? totalPerformance / employeeCount : 0.0;
  } catch (e) {
    print('Error al calcular el rendimiento promedio general: $e');
    return 0.0;
  }
}

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
          actions: [
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Color.fromARGB(255, 255, 255, 255), // Color naranja
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Reemplaza con tu pantalla de login
                );
              },
              tooltip: 'Cerrar sesión',
            ),
          ],
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
                    child: FutureBuilder<double>(
                      future: calculateGeneralAveragePerformance(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text(
                            'Error',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          );
                        } else {
                          double averagePerformance = snapshot.data ?? 0.0;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                averagePerformance.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: averagePerformance >= 10 ? Colors.green : Colors.red,
                                ),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  _showInfoDialog(context);
                                },
                                icon: Icon(Icons.info_outline),
                                tooltip: 'Información sobre rendimiento',
                              ),
                            ],
                          );
                        }
                      },
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información sobre el Rendimiento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF07154C),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'El rendimiento se calcula dividiendo la distancia recorrida entre la gasolina consumida en cada reporte. El promedio general refleja la eficiencia en el uso de combustible.',
              style: TextStyle(fontSize: 16, color: Color(0xFF07154C)),
            ),
            SizedBox(height: 12),
            Text(
              'Interpretación de colores:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF07154C),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '- Azul: Rendimiento inusual o excesivo.',
              style: TextStyle(fontSize: 15, color: Colors.blue),
            ),
            SizedBox(height: 4),
            Text(
              '- Verde: Buen rendimiento.',
              style: TextStyle(fontSize: 15, color: Colors.green),
            ),
            SizedBox(height: 4),
            Text(
              '- Amarillo: Rendimiento moderado.',
              style: TextStyle(fontSize: 15, color: Colors.orange),
            ),
            SizedBox(height: 4),
            Text(
              '- Rojo: Rendimiento bajo. Revisar unidad o hábitos de conducción.',
              style: TextStyle(fontSize: 15, color: Colors.red),
            ),
            SizedBox(height: 16),
            Center(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close, color: Colors.grey),
                tooltip: 'Cerrar',
              ),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerformanceScreen extends StatefulWidget {
  @override
  _PerformanceScreenState createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  String _selectedFilter = 'Rendimiento'; // Filtro inicial


Future<List<Map<String, dynamic>>> getEmployees() async {
  try {
    // Obtener todos los usuarios con rol "employee"
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .get();

    // Crear una lista con la información de cada empleado
    List<Map<String, dynamic>> employees = snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'email': data['email'],
        'name': data['employee_name'] ?? '', // Puedes ajustar el campo según el esquema en Firebase
      };
    }).toList();

    return employees;
  } catch (e) {
    print('Error al obtener la lista de empleados: $e');
    return [];
  }
}

Future<double> calculateAveragePerformanceForEmployee(String email) async {
  try {
    // Obtener los últimos 3 reportes del empleado
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('reports')
        .where('email', isEqualTo: email)
        .orderBy('date', descending: true)
        .limit(3)
        .get();

    if (snapshot.docs.length < 2) {
      // Si hay menos de 2 reportes válidos, no se puede calcular el rendimiento
      return 0.0;
    }

    double totalKm = 0;
    double totalLiters = 0;
    int? lastOdometer;

    var reports = snapshot.docs.reversed.toList();

    for (var doc in reports) {
      var data = doc.data() as Map<String, dynamic>;
      int odometerReading = data['odometer_reading'] ?? 0;
      int gasolineLiters = data['gasoline_liters'] ?? 0;

      // Solo calcula la distancia si tenemos un kilometraje previo válido
      if (lastOdometer != null && odometerReading > lastOdometer) {
        totalKm += (odometerReading - lastOdometer);
        totalLiters += gasolineLiters;
      } else if (lastOdometer == null) {
        lastOdometer = odometerReading;
      }

      lastOdometer = odometerReading;
    }

    // Calcular el rendimiento promedio
    return (totalLiters > 0) ? totalKm / totalLiters : 0.0;
  } catch (e) {
    print('Error al calcular el rendimiento para $email: $e');
    return 0.0;
  }
}

Future<List<Map<String, dynamic>>> getEmployeesWithPerformance() async {
  List<Map<String, dynamic>> employees = await getEmployees();

  // Crear una lista para almacenar empleados con su rendimiento
  List<Map<String, dynamic>> employeesWithPerformance = [];

  for (var employee in employees) {
    double performance = await calculateAveragePerformanceForEmployee(employee['email']);
    employeesWithPerformance.add({
      'name': employee['name'],
      'email': employee['email'],
      'performance': performance,
    });
  }

  // Ordenar la lista de empleados de mejor a peor rendimiento
  employeesWithPerformance.sort((a, b) => b['performance'].compareTo(a['performance']));

  return employeesWithPerformance;
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Color(0xFF07154C),
          automaticallyImplyLeading: false,
          flexibleSpace: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder(
              future: getEmployeesWithPerformance(),
              builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los datos'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay datos de rendimiento disponibles'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var employee = snapshot.data![index];
                    Color rendimientoColor;

                    if (employee['performance'] > 20) {
                      rendimientoColor = Colors.blue;
                    } else if (employee['performance'] >= 10) {
                      rendimientoColor = Colors.green;
                    } else if (employee['performance'] >= 7) {
                      rendimientoColor = Colors.yellow[700]!;
                    } else {
                      rendimientoColor = Colors.red;
                    }

                    return ListTile(
                      title: Text(employee['name']),
                      subtitle: Text('Rendimiento: ${employee['performance'].toStringAsFixed(1)}'),
                      trailing: CircleAvatar(
                        backgroundColor: rendimientoColor,
                        child: Text(employee['performance'].toStringAsFixed(1)),
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
                'Este rendimiento se calcula usando el kilometraje, litros de gasolina, etc.',
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

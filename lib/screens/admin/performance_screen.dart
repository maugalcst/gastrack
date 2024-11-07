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

  Future<double> calculateOverallAveragePerformance() async {
    List<Map<String, dynamic>> employees = await getEmployees();
    double totalPerformance = 0;
    int count = 0;

    for (var employee in employees) {
      double performance = await calculateAveragePerformanceForEmployee(employee['email']);
      if (performance > 0) {
        totalPerformance += performance;
        count++;
      }
    }
    return count > 0 ? totalPerformance / count : 0.0;
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

    // Ordenar la lista según el filtro seleccionado
    if (_selectedFilter == 'Conductor') {
      // Ordena alfabéticamente por nombre (email en este caso)
      employeesWithPerformance.sort((a, b) => a['email'].compareTo(b['email']));
    } else if (_selectedFilter == 'Rendimiento') {
      // Ordena de mejor a peor rendimiento
      employeesWithPerformance.sort((a, b) => b['performance'].compareTo(a['performance']));
    }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rendimiento',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF07154C),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Aquí puede observar a más detalle el rendimiento que han tenido todas las unidades y usuarios.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 16),
                Center(
                  child: FutureBuilder<double>(
                    future: calculateOverallAveragePerformance(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      double overallAverage = snapshot.data ?? 0.0;
                      return Column(
                        children: [
                          Text(
                            'Rendimiento General',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF07154C),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            overallAverage.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: overallAverage >= 10 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Detalles',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF07154C),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Filtrar por:',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    SizedBox(width: 6),
                    ChoiceChip(
                      label: Text(
                        'Conductor',
                        style: TextStyle(color: _selectedFilter == 'Conductor' ? Colors.white : Color(0xFF07154C)),
                      ),
                      selected: _selectedFilter == 'Conductor',
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedFilter = 'Conductor';
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Color(0xFF07154C),
                    ),
                    SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(
                        'Rendimiento',
                        style: TextStyle(color: _selectedFilter == 'Rendimiento' ? Colors.white : Color(0xFF07154C)),
                      ),
                      selected: _selectedFilter == 'Rendimiento',
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedFilter = 'Rendimiento';
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Color(0xFF07154C),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Expanded(
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

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Conductor',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF07154C),
                                  ),
                                ),
                                Text(
                                  'Rendimiento',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF07154C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: Colors.grey[400]), // Línea divisoria debajo de los encabezados
                          Expanded(
                            child: ListView.builder(
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

                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              employee['email'], // Muestra el email del empleado registrado
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF07154C),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                                            decoration: BoxDecoration(
                                              color: rendimientoColor.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              employee['performance'].toStringAsFixed(1),
                                              style: TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold,
                                                color: rendimientoColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(color: Colors.grey[300]), // Línea divisoria entre filas
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

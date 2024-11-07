import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrack_uanl/screens/employee/fuel_report_form_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Para dar formato a la fecha
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';  // Para auto ajustar texto
import 'package:gastrack_uanl/screens/login_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  @override
  _EmployeeDashboardScreenState createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        // Ajuste de altura de la barra superior
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF07154C),
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            // Espacio superior para ajustar el logo
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
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
                    MaterialPageRoute(
                        builder: (context) => FuelReportFormScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(
                      double.infinity, 50), // Para que ocupe todo el ancho
                ).copyWith(
                  backgroundColor: MaterialStateProperty.all(
                      Colors.transparent),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 9, 28, 101),
                        Color.fromARGB(255, 152, 67, 7)
                      ], // Azul a Naranja
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

              FutureBuilder(
                future: _calculateAveragePerformance(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Muestra un indicador de carga mientras se obtiene el valor
                  }
                  if (snapshot.hasError) {
                    return Text(
                        'Error'); // Muestra un mensaje de error si ocurre uno
                  }

                  // Define el color de fondo del contenedor y el texto basado en el valor del rendimiento promedio
                  double rendimiento = snapshot.data ?? 0.0;
                  if (rendimiento >= 30) {
                    rendimiento = 30;
                  }
                  Color contenedorColor;
                  Color rendimientoColor;
                  String rendimientoMessage = "";

                  if (rendimiento > 20) {
                    contenedorColor = const Color.fromARGB(255, 199, 228, 252);
                    rendimientoColor = Colors.blue;
                    rendimientoMessage = "Rendimiento inusualmente alto";
                  } else if (rendimiento >= 10) {
                    contenedorColor = const Color.fromARGB(255, 210, 232, 211);
                    rendimientoColor = Colors.green;
                    rendimientoMessage = "Excelente rendimiento";
                  } else if (rendimiento >= 7) {
                    contenedorColor = Colors.yellow[100]!;
                    rendimientoColor = Colors.yellow[700]!;
                    rendimientoMessage = "Buen rendimiento";
                  } else if (rendimiento > 0) {
                    contenedorColor = const Color.fromARGB(255, 245, 212, 215);
                    rendimientoColor = Colors.red;
                    rendimientoMessage = "Rendimiento bajo";
                  } else {
                    contenedorColor = Colors.grey[300]!;
                    rendimientoColor = Colors.grey;
                  }
// Obtener el tamaño de la pantalla
                  Size screenSize = MediaQuery
                      .of(context)
                      .size;

                  double containerWidth = screenSize.width *
                      0.95; // El contenedor ocupará el 90% del ancho de la pantalla
                  return Container(

                    width: containerWidth,
                    // Establece el ancho basado en el tamaño de la pantalla
                    padding: EdgeInsets.symmetric(
                        vertical: 16, horizontal: containerWidth * 0.05),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: contenedorColor, // Color de fondo según el rendimiento
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container
                          (
                          child: Column(
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
                                rendimientoMessage,
                                // Muestra el mensaje contextual
                                style: TextStyle(fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: rendimientoColor),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                textAlign: TextAlign.center,
                                rendimiento > 0
                                    ? rendimiento.toStringAsFixed(1)
                                    : "N/A",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: rendimientoColor,
                                ),
                                minFontSize: 12,
                                // Define un tamaño mínimo para la fuente
                                maxLines: 1,
                                // Limita a una sola línea de texto
                                overflow: TextOverflow
                                    .ellipsis, // Añade puntos suspensivos si el texto se corta
                              ),
                              Container(
                                width: 30,
                                child: IconButton(

                                  onPressed: () {
                                    _showInfoDialog(context);
                                  },
                                  icon: Icon(
                                    Icons.info_outline,
                                    size: 20.0, // Establece el tamaño del icono de forma manual
                                  ),
                                  tooltip: 'Ver detalles del rendimiento',
                                ),

                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
                    .where('email',
                    isEqualTo: FirebaseAuth.instance.currentUser!
                        .email) // Filtro por el email del usuario autenticado
                    .orderBy('date', descending: true)
                    .limit(3)
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
                          title: Text(
                              'Fecha: ${DateFormat('dd/MM/yy').format(date)}'),
                          subtitle: Text(
                              'Unidad: ${reportData['unit_number']}'),
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

  Future<double> _calculateAveragePerformance() async {
    final User? user = FirebaseAuth.instance
        .currentUser; // Obtén el usuario autenticado actual
    final userEmail = user?.email; // Obtén el email del usuario autenticado

    if (userEmail == null) {
      print('Usuario no autenticado');
      return 0.0;
    }

    try {
      // Consulta solo los últimos 3 reportes del usuario específico
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('email', isEqualTo: userEmail)
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
      int validReportCount = 0; // Contador de reportes con rendimiento válido

      // Procesa los reportes en orden cronológico
      var reports = snapshot.docs.reversed.toList();

      for (var doc in reports) {
        var data = doc.data() as Map<String, dynamic>;
        int odometerReading = data['odometer_reading'] ?? 0;
        int gasolineLiters = data['gasoline_liters'] ?? 0;

        // Solo calcula la distancia si tenemos un kilometraje previo válido
        if (lastOdometer != null && odometerReading > lastOdometer) {
          totalKm += (odometerReading - lastOdometer);
          totalLiters +=
              gasolineLiters; // Solo suma litros cuando se cuenta distancia
          validReportCount++; // Incrementa el contador de reportes válidos
        } else if (lastOdometer == null) {
          // Este es el primer reporte, lo usamos solo para establecer el kilometraje inicial
          lastOdometer = odometerReading;
        }

        // Actualiza lastOdometer después de cada reporte
        lastOdometer = odometerReading;
      }

      // Calcula el rendimiento promedio si hay litros de gasolina registrados y al menos un reporte válido
      return (totalLiters > 0 && validReportCount > 0)
          ? totalKm / totalLiters
          : 0.0;
    } catch (e) {
      print('Error al calcular el rendimiento promedio: $e');
      return 0.0; // Valor por defecto en caso de error
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
                Text('Fecha: ${DateFormat('dd/MM/yy').format(
                    report['date'].toDate())}'),
                Text('Unidad: ${report['unit_number']}'),
                Text('Kilometraje: ${report['odometer_reading']}'),
                Text('Litros de Gasolina: ${report['gasoline_liters']}'),
                SizedBox(height: 10),
                // Mostrar la imagen del ticket de gasolina
                Text('Ticket de Gasolina:'),
                //Image.network(report['gasoline_receipt_image_url']),
                SizedBox(height: 10),
                CachedNetworkImage(
                  imageUrl: report['gasoline_receipt_image_url'],
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                SizedBox(height: 10),
                // Mostrar la imagen del odómetro
                Text('Odómetro:'),
                //Image.network(report['odometer_image_url']),
                SizedBox(height: 10),
                CachedNetworkImage(
                  imageUrl: report['odometer_image_url'],
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
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
          content: SingleChildScrollView( // Agregamos SingleChildScrollView aquí
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Información sobre el rendimiento',
                  style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF07154C)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'El rendimiento general se calcula en base a los tres últimos reportes registrados, dividiendo los kilómetros recorridos entre los litros de gasolina consumidos en ese período. Este valor indica cuántos kilómetros recorre la unidad por cada litro de gasolina.',
                  style: TextStyle(fontSize: 16, color: Color(0xFF07154C)),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 20),
                Text(
                  'Interpretación de los colores:',
                  style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF07154C)),
                ),
                SizedBox(height: 10),
                Text(
                  '• Verde: Buen rendimiento (10 km/L o más).\n'
                      '• Amarillo: Rendimiento moderado (7 a 9.9 km/L).\n'
                      '• Rojo: Bajo rendimiento (menor a 7 km/L).\n'
                      '• Azul: Rendimiento inusualmente alto (mayor a 20 km/L).',
                  style: TextStyle(fontSize: 14, color: Color(0xFF07154C)),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 20),
                Text(
                  'Si el rendimiento es demasiado alto o bajo, puede indicar problemas con la unidad o en el registro de los datos. Por favor, verifique siempre el odómetro y el ticket de gasolina al registrar un reporte.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.justify,
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

//Vista para ver todos los reportes

class _AllReportsScreenState extends State<AllReportsScreen> {
  String _selectedOrder = 'Fecha';

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery
        .of(context)
        .size
        .height;
    double width = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todos mis reportes',
          style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 7, 21, 76),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email) // Filtro por el email del usuario autenticado
                  .orderBy('date', descending: true) // Ordenar solo por fecha
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
                        title: Text('Fecha: ${DateFormat('dd/MM/yy').format(
                            date)}'),
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
                //Image.network(report['gasoline_receipt_image_url']),
                SizedBox(height: 10),
                CachedNetworkImage(
                  imageUrl: report['gasoline_receipt_image_url'],
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                SizedBox(height: 10),
                // Mostrar la imagen del odómetro
                Text('Odómetro:'),
                //Image.network(report['odometer_image_url']),
                SizedBox(height: 10),
                CachedNetworkImage(
                  imageUrl: report['odometer_image_url'],
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
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

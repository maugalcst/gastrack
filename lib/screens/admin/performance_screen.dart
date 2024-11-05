import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerformanceScreen extends StatefulWidget {
  @override
  _PerformanceScreenState createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  String _selectedFilter = 'Rendimiento'; // Filtro inicial

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
                'GasTrack', // Logo de la app (asegúrate de que esté alineado como quieres)
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
          // Fondo con degradado tenue
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 209, 217, 255), // Azul tenue en la parte superior
                  Colors.white, // Blanco en la parte inferior
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de Rendimiento General
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Rendimiento General',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF07154C),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '82.5', // Este valor se actualizará dinámicamente
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
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

                // Sección de Filtros
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detalles',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF07154C),
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedFilter,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFilter = newValue!;
                          // Aquí aplicaremos la lógica de filtrado en el futuro
                        });
                      },
                      items: <String>['Rendimiento', 'Alfabético']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Tabla de Rendimiento Individual
                Expanded(
                  child: ListView.builder(
                    itemCount: 10, // Número de empleados (esto se actualizará con datos reales)
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: index % 2 == 0 ? Colors.green : Colors.red, // Placeholder
                            child: Icon(
                              index % 2 == 0 ? Icons.arrow_upward : Icons.arrow_downward,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            'Nombre Empleado $index', // Placeholder
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF07154C),
                            ),
                          ),
                          subtitle: Text(
                            'Rendimiento: ${(70 + index).toString()}%', // Placeholder
                            style: TextStyle(
                              color: index % 2 == 0 ? Colors.green : Colors.red, // Placeholder
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF07154C)),
                          onTap: () {
                            // Acciones al tocar el elemento (por ejemplo, ver detalles del empleado)
                          },
                        ),
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

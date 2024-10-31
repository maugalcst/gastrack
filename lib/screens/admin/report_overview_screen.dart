import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'performance_screen.dart';

class ReportOverviewScreen extends StatefulWidget {
  @override
  _ReportOverviewScreenState createState() => _ReportOverviewScreenState();
}

class _ReportOverviewScreenState extends State<ReportOverviewScreen> {
  String _selectedFilter = 'conductor';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF07154C),
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
                  decorationColor: Colors.orange,
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
                  Color.fromARGB(255, 232, 236, 255),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reportes',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF07154C),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.menu, color: Color(0xFF07154C)),
                        onPressed: () {
                          _showMenu(context);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aquí puede observar y descargar los reportes que se han registrado así como historial de reportes de los usuarios.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF07154C),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'conductor';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedFilter == 'conductor'
                              ? Color.fromARGB(255, 9, 27, 100)
                              : Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Conductor',
                          style: TextStyle(
                            color: _selectedFilter == 'conductor'
                                ? Colors.white
                                : Color.fromARGB(255, 9, 27, 100),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedFilter = 'unidad';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedFilter == 'unidad'
                              ? Color(0xFF07154C)
                              : Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Unidad',
                          style: TextStyle(
                            color: _selectedFilter == 'unidad'
                                ? Colors.white
                                : Color.fromARGB(255, 9, 27, 100),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    _selectedFilter == 'conductor'
                        ? 'Reportes por conductor'
                        : 'Reportes por unidad',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 9, 27, 100),
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildTableHeader(),
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return _buildReportRow(
                        name: _selectedFilter == 'conductor'
                            ? 'Nombre ${index + 1}'
                            : 'Unidad ${index + 1}',
                        id: 'ID${index + 1}',
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

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Nombre',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 9, 27, 100),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'No. Emp',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 9, 27, 100),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Reporte',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 9, 27, 100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow({required String name, required String id}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                name,
                style: TextStyle(color: Color(0xFF07154C), fontSize: 16),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                id,
                style: TextStyle(color: Color(0xFF07154C), fontSize: 16),
              ),
            ),
            Container(
              width: 70, // Ancho del botón para hacerlo más compacto
              height: 40, // Alto del botón
              child: ElevatedButton(
                onPressed: () {
                  // Acción para ver el reporte
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 18, 90, 207), // Color del botón "Ver"
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 0), // Ajusta el padding interno
                ),
                child: Text(
                  'Ver',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
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

  // Botón "Ver"
  Widget _buildViewButton() {
    return Container(
      height: 40,
      width: 80,
      child: ElevatedButton(
        onPressed: () {
          // Agrega la funcionalidad de "Ver" aquí
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3366FF), // Cambia el color del botón a azul
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordes más redondeados
          ),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Ajusta el padding
        ),
        child: Text(
          'Ver',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
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

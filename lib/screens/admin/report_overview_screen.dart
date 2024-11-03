import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gastrack_uanl/screens/admin/report_details_screen.dart';

class ReportOverviewScreen extends StatefulWidget {
  @override
  _ReportOverviewScreenState createState() => _ReportOverviewScreenState();
}

class _ReportOverviewScreenState extends State<ReportOverviewScreen> {
  Set<String> employeeEmails = {}; // Para almacenar emails únicos

  @override
  void initState() {
    super.initState();
    _fetchEmployeeEmails();
  }

  Future<void> _fetchEmployeeEmails() async {
    try {
      // Consulta la colección 'users' para obtener los emails de los empleados con rol 'employee'
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'employee')
          .get();

      // Extrae los emails únicos de los documentos
      setState(() {
        employeeEmails = snapshot.docs
            .map((doc) => doc['email'] as String)
            .toSet(); // Convierte a conjunto para evitar duplicados
      });

      // Imprime el conjunto de emails para verificar su contenido
      print("Emails obtenidos: $employeeEmails");
    } catch (e) {
      print("Error al obtener emails de empleados: $e");
    }
  }


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
                  Text(
                    'Reportes por conductor',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 9, 27, 100),
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildTableHeader(),
                  SizedBox(height: 8),
                  // Lista de emails con botón "Ver"
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: employeeEmails.length,
                    itemBuilder: (context, index) {
                      String email = employeeEmails.elementAt(index);
                      return _buildReportRow(
                        name: email,
                        id: 'A32', // Placeholder, se puede actualizar si es necesario
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
              width: 70,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportDetailsScreen(
                        employeeEmail: name, // Pasamos el email del empleado
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 18, 90, 207),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
}
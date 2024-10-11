import 'package:flutter/material.dart';

class FuelReportFormScreen extends StatefulWidget {
  @override
  _FuelReportFormScreenState createState() => _FuelReportFormScreenState();
}

class _FuelReportFormScreenState extends State<FuelReportFormScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controladores de texto para validación
  final TextEditingController _driverController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de la aplicación con el color azul rey
          Container(
            color: Color.fromARGB(255, 1, 16, 62), // Color azul rey de fondo
          ),
          Column(
            children: [
              // Barra superior personalizada con degradado
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 0, 7, 65), Color.fromARGB(255, 106, 44, 0)], // Degradado de azul a naranja
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'GasTrack',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.orange,
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildDriverInfoSlide(),
                    _buildTicketPhotoSlide(),
                    _buildTicketDetailsSlide(),
                    _buildOdometerPhotoSlide(),
                    _buildOdometerConfirmationSlide(),
                  ],
                ),
              ),
              _buildContinueButton(),
              _buildBottomStepper(),
            ],
          ),
        ],
      ),
    );
  }

  // Slide 1: Información del conductor
  Widget _buildDriverInfoSlide() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registro de Gasolina',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Rellena todo lo que se te pide, ten el ticket a la mano y el odómetro cerca',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 30),
          _buildTextField('Nombre del conductor', 'Mauricio Gallegos', _driverController),
          SizedBox(height: 20),
          _buildTextField('Número de unidad', 'N24 por ejemplo', _unitController),
        ],
      ),
    );
  }

  // Campo de texto personalizado
  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30), // Bordes semicirculares
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  // Botón de continuar
  Widget _buildContinueButton() {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.transparent,
      child: ElevatedButton(
        onPressed: _canMoveTo(_currentPage + 1)
            ? () {
                if (_currentPage < 4) {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF6A00), // Botón con color naranja
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
          minimumSize: Size(double.infinity, 50), // Botón de ancho completo
        ),
        child: Text(
          'Continuar',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  // Barra inferior con iconos
  Widget _buildBottomStepper() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepperIcon(Icons.person, 0),
          _buildStepperIcon(Icons.local_gas_station, 1),
          _buildStepperIcon(Icons.directions_car, 2),
        ],
      ),
    );
  }

  // Icono de cada paso
  Widget _buildStepperIcon(IconData icon, int stepIndex) {
    return GestureDetector(
      onTap: () {
        if (_canMoveTo(stepIndex)) {
          _pageController.animateToPage(stepIndex, duration: Duration(milliseconds: 300), curve: Curves.ease);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: _currentPage == stepIndex ? Colors.orange : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.orange, width: 2),
        ),
        padding: EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 30,
          color: _currentPage == stepIndex ? Colors.white : Colors.orange,
        ),
      ),
    );
  }

  // Lógica de validación para los pasos
  bool _canMoveTo(int stepIndex) {
    if (stepIndex == 1 && (_driverController.text.isEmpty || _unitController.text.isEmpty)) {
      return false; // Bloquear si no se ha llenado el formulario del conductor
    }
    return true;
  }










  // Slide 2: Foto del ticket de gasolina
  Widget _buildTicketPhotoSlide() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 100, color: Color(0xFF002241)),
          SizedBox(height: 16),
          Text(
            'Tome una foto al ticket de compra de gasolina',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Slide 3: Detalles del ticket de gasolina
  Widget _buildTicketDetailsSlide() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Importe del ticket',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: '600.00 por ejemplo',
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Litros comprados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: '2 por ejemplo',
            ),
          ),
        ],
      ),
    );
  }

  // Slide 4: Foto del odómetro
  Widget _buildOdometerPhotoSlide() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 100, color: Color(0xFF002241)),
          SizedBox(height: 16),
          Text(
            'Tome una foto al odómetro de su unidad (el kilometraje)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Slide 5: Confirmación de kilometraje
  Widget _buildOdometerConfirmationSlide() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kilometraje de unidad',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: '64618 por ejemplo',
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Aquí iría la funcionalidad para enviar los datos
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text('Registro creado con éxito'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Aceptar'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  // Paso 3: Crear botones de navegación
  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 0
                ? () {
                    _pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                : null,
            child: Text('Anterior'),
          ),
          ElevatedButton(
            onPressed: _currentPage < 4
                ? () {
                    _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                : null,
            child: Text('Siguiente'),
          ),
        ],
      ),
    );
  }
}

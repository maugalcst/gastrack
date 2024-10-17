import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gastrack_uanl/screens/employee/employee_dashboard_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore

class FuelReportFormScreen extends StatefulWidget {
  @override
  _FuelReportFormScreenState createState() => _FuelReportFormScreenState();
}

class _FuelReportFormScreenState extends State<FuelReportFormScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String button_text = "Continuar";
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  XFile? _image2;

  // Controladores de texto para validación
  final TextEditingController _driverController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _importController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _odometerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double slider_h = height * 0.6;
    double slider_w = width * 0.8;

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
             _buildUpperLogo(height * 0.14),
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
                    _buildTicketPhotoSlide(slider_h, slider_w),
                    _buildTicketDetailsSlide(),
                    _buildOdometerPhotoSlide(slider_h, slider_w),
                    _buildOdometerConfirmationSlide(),
                  ],
                ),
              ),
              _buildContinueButton(height * 0.06, width * 0.8),
              _buildBottomStepper(height * 0.1, width * 0.8),
            ],
          ),
        ],
      ),
    );
  }

  // Función para subir imágenes a Firebase Storage
  Future<String> uploadImageToStorage(String filePath, String fileName) async {
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = storageRef.putFile(File(filePath));
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error al subir la imagen: $e');
      return '';
    }
  }

  // Función para guardar el reporte en Firestore
  Future<void> saveReportToFirestore({
    required String employeeName,
    required String unitNumber,
    required int odometerReading,
    required int gasolineLiters,
    required String gasolineReceiptImageUrl,
    required String odometerImageUrl,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'employee_name': employeeName,
        'unit_number': unitNumber,
        'odometer_reading': odometerReading,
        'gasoline_liters': gasolineLiters,
        'gasoline_receipt_image_url': gasolineReceiptImageUrl,
        'odometer_image_url': odometerImageUrl,
        'date': Timestamp.now(),
      });
      print('Reporte guardado exitosamente');
    } catch (e) {
      print('Error al guardar el reporte: $e');
    }
  }

  // Botón continuar único
  Widget _buildContinueButton(double height, double width) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      width: width,
      height: height,
      color: Colors.transparent,
      child: ElevatedButton(
        onPressed: _canMoveTo(_currentPage + 1) ? () async {
          if (_currentPage < 4) {
            _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            if (_currentPage == 3) {
              button_text = "Subir reporte";
            } else {
              button_text = "Continuar";
            }
          } else {
            // Subir imágenes a Firebase Storage y guardar el reporte
            String gasolineReceiptUrl = await uploadImageToStorage(_image!.path, 'receipt_${_unitController.text}');
            String odometerImageUrl = await uploadImageToStorage(_image2!.path, 'odometer_${_unitController.text}');

            await saveReportToFirestore(
              employeeName: _driverController.text,
              unitNumber: _unitController.text,
              odometerReading: int.parse(_odometerController.text),
              gasolineLiters: int.parse(_litersController.text),
              gasolineReceiptImageUrl: gasolineReceiptUrl,
              odometerImageUrl: odometerImageUrl,
            );

            // Navega de regreso al dashboard
            Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeDashboardScreen()));
          }
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF6A00), // Color naranja
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 0),
        ),
        child: Text(
          button_text,
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }


  Widget _buildUpperLogo(double height)
  {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: Container(
        height: height,
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
    );
  }

  // Slide 1: Información del conductor
  Widget _buildDriverInfoSlide() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Texto 2
          Text(
            'Registro de Gasolina',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          //texto 3
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

  // Textbox
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
            onChanged: (value)
            {
              setState(() {}); // Actualiza el estado cuando cambia el texto
            },
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

  //GASOLINA

  //Slide 2: Foto del ticket de gasolina
  Widget _buildTicketPhotoSlide(double height, double width)
  {
    double container_h = height * 0.6;
    double container_w = width * 0.9;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: height * 0.05, horizontal: width * 0.1),
    child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Registro de gasolina',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: height*0.05),
          Text(
            'Tome una foto del ticket de compra de gasolina, asegúrese de que sea legible y clara.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          SizedBox(height: height*0.1),
          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            height: container_h,
            width: container_w,
            decoration: BoxDecoration(
              color: Color(0xFF000817), // Color azul oscuro
              borderRadius: BorderRadius.circular(16),
            ),
            child: _image != null
                ? Image.file(
              File(_image!.path),
              fit: BoxFit.cover,
            )
                : _buildCameraButton(container_h/2, container_w, 1),
          ),

          ]
    )
    );
  }

  // Slide 3: Detalles del ticket de gasolina
  Widget _buildTicketDetailsSlide() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          _buildTextField('Importe del ticket', '600.00 por ejemplo', _importController),
          SizedBox(height: 16),
          _buildTextField('Litros comprados', '2 por ejemplo', _litersController),
        ],
      ),
    );
  }

  //ODOMETRO

  // Slide 4: Foto del odómetro
  Widget _buildOdometerPhotoSlide(double height, double width)
  {
    double container_h = height * 0.5;
    double container_w = width * 0.9;

    return Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.05, horizontal: width * 0.1),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Registro de odometraje',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: height*0.05),
              Text(
                'Tome una foto al odómetro de su unidad (el kilometraje)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              SizedBox(height: height*0.1),
              Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                height: container_h,
                width: container_w,
                decoration: BoxDecoration(
                  color: Color(0xFF000817), // Color azul oscuro
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _image2 != null
                    ? Image.file(
                  File(_image2!.path),
                  fit: BoxFit.cover,
                )
                    : _buildCameraButton(container_h/2, container_w, 2),
              ),

            ]
        )
    );
  }

  // Slide 5: Confirmación de kilometraje
  Widget _buildOdometerConfirmationSlide() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          _buildTextField('Kilometraje de unidad', '64618 por ejemplo', _odometerController),
        ],
      ),
    );
  }

  // Boton camara:
  Widget _buildCameraButton(double height, double width, int number)
  {
    double icon_size = height*0.6;
    double separation = height*0.05;
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: width*0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
            onPressed: () async {
              final XFile? image = await _picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 100,
              );
              setState(() {
                if (number == 1)
                  {
                    _image = image;
                  }
               if (number == 2)
                 {
                   _image2 = image;
                 }
              });
              },
              icon:  Icon(Icons.camera_alt, color: Colors.grey, size: icon_size),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF000817),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // Bordes redondeados
        ),
              ),
            ),
            SizedBox(height: separation),
            AutoSizeText(
              'Presione la camara para tomar una foto del ticket',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
              maxLines: 2,
              minFontSize: 6,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            )
          ],
        ),
    );
  }

  // Barra inferior con iconos
  Widget _buildBottomStepper(double height, double width) {
    return Container(
      height: height,
      width: width,
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepperIcon(Icons.person, 0),
          _buildStepperIcon(Icons.local_gas_station, 1),
          _buildStepperIcon(Icons.directions_car, 3),
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
          color: Colors.orange,
          shape: BoxShape.circle,
          border: Border.all(color: _shouldLight(_currentPage, stepIndex) ? Colors.white : Colors.orange, width: 4), // Cambiar aquí
        ),
        padding: EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 30,
          color: Colors.white, // Cambiar aquí
        ),
      ),
    );
  }

  //Logica para decidir que boton se debe iluminar
  bool _shouldLight(int currentPage, int stepIndex)
  {
    if (stepIndex == 0 && currentPage == stepIndex)
      {
        return true;
      }
    if (stepIndex == 1 && (currentPage == stepIndex || currentPage == stepIndex+1))
    {
      return true;
    }
    if (stepIndex == 3 && (currentPage == stepIndex || currentPage == stepIndex+1))
    {
      return true;
    }
    return false;
  }

  // Lógica de validación para los pasos
  bool _canMoveTo(int stepIndex) {
    if (stepIndex == 0) {
      return true;
    }
    if (stepIndex == 1) {
      return _driverController.text.isNotEmpty && _unitController.text.isNotEmpty;
    }
    if (stepIndex == 2)
    {
      return (_image != null);
    }
    if (stepIndex == 3)
    {
      return _importController.text.isNotEmpty && _litersController.text.isNotEmpty;
    }
    if (stepIndex == 4)
    {
      return (_image2 != null);
    }

    if (stepIndex == 5)
    {
      return _odometerController.text.isNotEmpty;
    }

    return false;
  }

  //BOTONES DE NAVEGACION

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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navegar a la página de Login después de 1.7 segundos
    Future.delayed(Duration(milliseconds: 1700), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 22, 65, 1), // Azul oscuro
      body: Stack(
        alignment: Alignment.center, // Centra ambos widgets en el Stack
        children: [
          _buildCenteredText(),
          _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildCenteredText() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        'GasTrack',
        style: GoogleFonts.inter(
          fontSize: 50,
          fontWeight: FontWeight.w900, // Grosor extra
          color: Color.fromARGB(255, 255, 255, 255),
          decoration: TextDecoration.underline,
          decorationColor: Colors.orange,
          decorationThickness: 2,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned(
      bottom: 30, // Ajusta la posición del círculo
      child: SizedBox(
        width: 120,
        height: 120,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          strokeWidth: 7.115,
        ),
      ),
    );
  }
}

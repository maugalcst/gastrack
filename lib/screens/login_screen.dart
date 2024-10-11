import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    // Aquí se agregará la lógica de inicio de sesión después.
    Navigator.pushReplacementNamed(context, '/employee_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFECF3FE), Color(0xFFD9E3F0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 120),
                      _buildTitle(),
                      SizedBox(height: 30),
                      _buildLoginText(),
                      SizedBox(height: 20),
                      _buildTextField('Usuario o Email', _emailController, false),
                      SizedBox(height: 20),
                      _buildTextField('Contraseña', _passwordController, true),
                      SizedBox(height: 40),
                      _buildLoginButton(),
                      SizedBox(height: 30),
                      _buildRegisterSection(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'GasTrack',
      style: GoogleFonts.inter(
        fontSize: 44,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0A1A3A),
        decoration: TextDecoration.underline,
        decorationColor: Colors.orange,
        decorationThickness: 2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginText() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Inicia sesión con tu cuenta',
        style: GoogleFonts.inter(
          fontSize: 18,
          color: Color(0xFF343A40),
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool obscureText) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF6C757D)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Color(0xFFADB5BD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: 220,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: LinearGradient(
          colors: [Color(0xFF0A1A3A), Color.fromARGB(255, 121, 46, 1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: _login,
        child: Text('Entrar', style: GoogleFonts.inter(color: Colors.white, fontSize: 20)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
      ),
    );
  }

  Widget _buildRegisterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('¿No tienes cuenta?', style: GoogleFonts.inter(color: Color(0xFF343A40), fontSize: 16)),
        TextButton(
          onPressed: () {},
          child: Text('Regístrate', style: GoogleFonts.inter(color: Colors.orange, fontSize: 16)),
        ),
      ],
    );
  }
}

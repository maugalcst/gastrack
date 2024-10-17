import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variable para mostrar el estado del error
  String? _errorMessage;

  // Método para manejar el login
  void _login() async {
    try {
      // Autenticación con Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Si el login es exitoso, obtener el rol desde Firestore
      String email = userCredential.user!.email!;
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();

      if (userDoc.exists) {
        // Obtener el rol del usuario
        String role = userDoc.data()!['role'];

        // Redirigir según el rol
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else if (role == 'employee') {
          Navigator.pushReplacementNamed(context, '/employee_dashboard');
        } else {
          // Manejar caso si el rol no está definido correctamente
          setState(() {
            _errorMessage = "Rol no definido correctamente. Contacta al administrador.";
          });
        }
      } else {
        // Si el usuario no existe en Firestore
        setState(() {
          _errorMessage = "No se pudo obtener el rol. Contacta al administrador.";
        });
      }
    } on FirebaseAuthException catch (e) {
      // Mostrar mensaje de error si la autenticación falla
      setState(() {
        _errorMessage = _getErrorMessage(e);  // Obtener el mensaje de error según el tipo
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Ocurrió un error inesperado. Intenta de nuevo.";
      });
    }
  }

  // Método para obtener un mensaje de error legible
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró el usuario con ese correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta. Por favor intenta de nuevo.';
      case 'invalid-email':
        return 'Correo electrónico inválido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      default:
        return 'Error desconocido. Intenta de nuevo.';
    }
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
                      if (_errorMessage != null) _buildErrorMessage(), // Mostrar mensaje de error si hay
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
      style: TextStyle(
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
        style: TextStyle(
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
        child: Text('Entrar', style: TextStyle(color: Colors.white, fontSize: 20)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        _errorMessage!,
        style: TextStyle(color: Colors.red, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRegisterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Color(0xFF343A40), fontSize: 16)),
        TextButton(
          onPressed: () {},
          child: Text('Recuperar Contraseña', style: TextStyle(color: Colors.orange, fontSize: 16)),
        ),
      ],
    );
  }
}

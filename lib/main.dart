import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importar Firebase Core
import 'firebase_options.dart'; // Importar el archivo de opciones generado por FlutterFire CLI
import 'screens/employee/employee_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart'; // Importar la pantalla de admin
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  // Asegúrate de inicializar los widgets antes de llamar a Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Firebase inicializado correctamente');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GasTrack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/employee_dashboard': (context) => EmployeeDashboardScreen(),
        '/admin_dashboard': (context) => AdminDashboardScreen(), // Ruta para el dashboard de admin
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gym_system/screens/WelcomeScreen.dart';
import 'package:gym_system/screens/listar_rutina.dart';
import 'package:gym_system/screens/login_screen.dart';
import 'package:gym_system/screens/profile_screen.dart'; // Asegúrate de que ProfileScreen.dart esté en el lugar correcto
import 'package:shared_preferences/shared_preferences.dart';

class NavegacionScreenApp extends StatelessWidget {
  final String token;
  const NavegacionScreenApp({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NavegacionScreen(token: token),
    );
  }
}

class NavegacionScreen extends StatefulWidget {
  final String token;

  const NavegacionScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<NavegacionScreen> createState() => _NavegacionScreenState();
}

class AuthService {
  // Método para obtener el token de autenticación almacenado en SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Método para cerrar sesión (limpiar el token de autenticación)
  Future<void> logout(BuildContext context) async {
    try {
      // Obtener el token actual antes de eliminarlo
      final tokenBeforeLogout = await getToken();
      print('Token antes de cerrar sesión: $tokenBeforeLogout');

      // Eliminar el token de autenticación de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');

      // Verificar si el token se eliminó correctamente
      final tokenAfterLogout = await getToken();
      print('Token después de cerrar sesión: $tokenAfterLogout');

      // Navegar de regreso a la pantalla de inicio de sesión
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Eliminar todas las rutas existentes
      );
    } catch (error) {
      print('Error al cerrar sesión: $error');
      // Manejar el error, si es necesario
    }
  }
}

class _NavegacionScreenState extends State<NavegacionScreen> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onNavigateToRutina(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _widgetOptions() {
    return [
      WelcomeScreen(onNavigateToRutina: _onNavigateToRutina),
      const RutinaScreen(),
      ProfileScreen(), // Actualiza esta línea para mostrar la pantalla de perfil
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions().elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
            backgroundColor: Color.fromARGB(255, 255, 87, 51),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Rutina',
            backgroundColor: Color.fromARGB(255, 255, 87, 51),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Perfil',
            backgroundColor: Color.fromARGB(255, 255, 87, 51),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:
            Colors.black, // Aquí cambias el color seleccionado a negro
        unselectedItemColor:
            Colors.grey, // Si quieres que los no seleccionados sean grises
        onTap: _onItemTapped,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gym_system/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse(
            'https://finalgymsystem.onrender.com/api/auth/usuario-autenticado'),
        headers: {
          'Content-Type': 'application/json',
          'x-token': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userInfo = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print('Error fetching user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    // Navegar a la pantalla de inicio de sesión y eliminar la pila de navegación
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const LoginScreen()), // Asegúrate de que LoginScreen esté importada
      (Route<dynamic> route) => false,
    );
  }

  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'No disponible';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 124, 57),
        title: const Row(
          children: [
            Icon(
              Icons.person,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Mi Perfil',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 80,
                    backgroundColor: Color.fromARGB(255, 201, 206, 214),
                    child: Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${userInfo['Nombres']} ${userInfo['Apellidos']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildProfileField('Correo:', userInfo['Correo']),
                          _buildProfileField(
                              'Teléfono:', userInfo['Telefono']?.toString()),
                          _buildProfileField(
                              'Documento:', userInfo['Documento']),
                          _buildProfileField('Fecha de Nacimiento:',
                              _formatDate(userInfo['FechaDeNacimiento'])),
                          _buildProfileField(
                              'Dirección:', userInfo['Direccion']),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 48, 48, 48),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value ?? 'No disponible',
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        ),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

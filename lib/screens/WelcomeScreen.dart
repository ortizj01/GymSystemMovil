import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  final Function(int) onNavigateToRutina; // Callback para cambiar la pantalla

  const WelcomeScreen({Key? key, required this.onNavigateToRutina})
      : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String nombreUsuario = "";
  Map<String, dynamic> rutinaDelDia = {};
  bool isLoading = true;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No se encontró el token');
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
        final userData = jsonDecode(response.body);
        final idUsuario = userData['IdUsuario'].toString();
        final nombre = userData['Nombres'] + ' ' + userData['Apellidos'];

        setState(() {
          nombreUsuario = nombre;
        });

        obtenerRutinaDelDia(idUsuario, token);
      } else {
        print('Error al obtener los datos del usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> obtenerRutinaDelDia(String idUsuario, String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://finalgymsystem.onrender.com/api/rutinas/completa/$idUsuario'),
        headers: {
          'Content-Type': 'application/json',
          'x-token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final diaActualNumero = DateTime.now().weekday;
        String diaActualClave = diaActualNumero.toString();

        Map<String, dynamic> rutinaDelDia = {};

        for (var rutina in data) {
          if (rutina['DiasSemana'] != null) {
            if (rutina['DiasSemana'][diaActualClave] != null) {
              final ejerciciosDelDia = rutina['DiasSemana'][diaActualClave];
              if (ejerciciosDelDia is List) {
                rutinaDelDia = {
                  'ejercicios': ejerciciosDelDia,
                };
              }
              break;
            }
          }
        }

        setState(() {
          this.rutinaDelDia = rutinaDelDia;
          isLoading = false;
        });
      } else {
        print('Error al obtener la rutina: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Bienvenid@',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 65, 65, 65),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                nombreUsuario,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Center(
                child: Image.asset(
                  'assets/images/logoGS.png',
                  width: 250, // Ajusta el tamaño de la imagen
                ),
              ),
              const SizedBox(height: 30),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (rutinaDelDia.isNotEmpty)
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  elevation: 5,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  margin: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Rutina del Día',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(isExpanded ? Icons.remove : Icons.add),
                              onPressed: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                            ),
                          ],
                        ),
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0;
                                i < rutinaDelDia['ejercicios'].length;
                                i++)
                              if (i < 2 || isExpanded)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rutinaDelDia['ejercicios'][i]
                                              ['NombreEjercicio'] ??
                                          '',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(rutinaDelDia['ejercicios'][i]
                                            ['DescripcionEjercicio'] ??
                                        ''),
                                    Text(
                                        'Series: ${rutinaDelDia['ejercicios'][i]['Series'] ?? ''}'),
                                    Text(
                                        'Repeticiones: ${rutinaDelDia['ejercicios'][i]['RepeticionesEjercicio'] ?? ''}'),
                                    const SizedBox(height: 15),
                                  ],
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onNavigateToRutina(
                        1); // Cambiar al índice 1 para la pantalla de rutinas
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .blueAccent, // Cambiado de primary a backgroundColor
                    foregroundColor:
                        Colors.white, // Cambiado de onPrimary a foregroundColor
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Ver rutina completa'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

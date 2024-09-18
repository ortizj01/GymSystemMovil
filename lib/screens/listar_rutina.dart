import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RutinaScreen extends StatefulWidget {
  const RutinaScreen({Key? key});

  @override
  State<RutinaScreen> createState() => _RutinaScreenState();
}

class _RutinaScreenState extends State<RutinaScreen> {
  Map<String, dynamic> rutina = {};
  bool isLoading = true;
  Map<String, bool> expandido = {}; // Estado para controlar la expansión

  @override
  void initState() {
    super.initState();
    _obtenerRutinaAsignada();
  }

  Future<void> _obtenerRutinaAsignada() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No se encontró el token');
      }

      var userUrl =
          Uri.parse('https://finalgymsystem.onrender.com/api/auth/usuario-autenticado');
      var userResponse = await http.get(
        userUrl,
        headers: {
          'Content-Type': 'application/json',
          'x-token': token,
        },
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Error al obtener el ID del usuario');
      }

      final userData = jsonDecode(userResponse.body);
      final idUsuario = userData['IdUsuario'];

      var rutinaUrl = Uri.parse(
          'https://finalgymsystem.onrender.com/api/rutinas/completa/$idUsuario');
      var rutinaResponse = await http.get(
        rutinaUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (rutinaResponse.statusCode != 200) {
        throw Exception('Error al obtener la rutina asignada');
      }

      setState(() {
        rutina = jsonDecode(rutinaResponse.body)[0]['DiasSemana'];
        // Inicializar todos los días como no expandidos
        expandido = rutina.keys.fold({}, (map, key) {
          map[key] = false;
          return map;
        });
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
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
              Icons.fitness_center,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Mi Rutina Asignada',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rutina.isEmpty
              ? const Center(child: Text('No hay rutinas asignadas'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: rutina.entries.map<Widget>((entry) {
                      final dia = int.tryParse(entry.key) ?? -1;
                      final ejercicios = entry.value;
                      final nombreDia = obtenerNombreDia(dia);
                      final isExpanded = expandido[entry.key] ?? false;

                      return Card(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Colors.blueAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        nombreDia,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(
                                        isExpanded ? Icons.remove : Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        expandido[entry.key] = !isExpanded;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.grey),
                              const SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Asegura la alineación a la izquierda
                                children: ejercicios
                                    .asMap()
                                    .entries
                                    .map<Widget>((ejercicioEntry) {
                                  final index = ejercicioEntry.key;
                                  final ejercicio = ejercicioEntry.value;

                                  // Mostrar todos los ejercicios si está expandido o solo el primero si no
                                  if (!isExpanded && index > 0) {
                                    return Container();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start, // Asegura la alineación a la izquierda
                                      children: [
                                        Text(
                                          ejercicio['NombreEjercicio'] ??
                                              'Sin nombre',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Descripción: ${ejercicio['DescripcionEjercicio'] ?? 'Sin descripción'}',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Series: ${ejercicio['Series'] ?? 'Sin series'}',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Repeticiones: ${ejercicio['RepeticionesEjercicio'] ?? 'Sin repeticiones'}',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
    );
  }

  String obtenerNombreDia(int numeroDia) {
    const diasSemana = {
      1: 'LUNES',
      2: 'MARTES',
      3: 'MIÉRCOLES',
      4: 'JUEVES',
      5: 'VIERNES',
      6: 'SÁBADO',
      7: 'DOMINGO',
    };
    return diasSemana[numeroDia] ?? 'Día desconocido';
  }
}

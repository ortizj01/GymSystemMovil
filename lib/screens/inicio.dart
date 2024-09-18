import 'package:flutter/material.dart';
import 'package:gym_system/screens/listar_rutina.dart';

class InicioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Color.fromARGB(255, 255, 87, 51),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: <Widget>[
            _buildCard(
              context,
              'Ver Rutinas',
              Icons.fitness_center,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RutinaScreen()),
                );
              },
            ),
            _buildCard(
              context,
              'Otro Elemento',
              Icons.star,
              () {
                // Acción para el otro elemento
              },
            ),
            // Agrega más tarjetas aquí
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 40,
                color: Color.fromARGB(255, 255, 87, 51),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

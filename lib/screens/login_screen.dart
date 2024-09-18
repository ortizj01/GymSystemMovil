import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_system/screens/menu_inferior.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formLogin =
      GlobalKey<FormState>(); //estado del formulario
  String correo = '';
  String password = '';

  void acceder(String correo, String password) async {
    var url = Uri.parse('https://finalgymsystem.onrender.com/api/auth/login');

    //se implementa el header para indicar a nodejs que estamos enviando parametros
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      var response = await http.post(
        url,
        headers: requestHeaders,
        body: jsonEncode({
          'Correo': correo, // Cambiado a 'Correo'
          'Contrasena': password, // Cambiado a 'Contrasena'
        }),
      );

      if (response.statusCode == 200) {
        // Procesar respuesta exitosa

        // Convertimos el cuerpo de la respuesta
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Accedemos al valor del token
        final String token = responseData['token'];
        print('Token Generado: $token'); // Extracción del token

        // Guardar el token en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NavegacionScreen(
              token: token,
            ),
          ),
        );
      } else {
        // Procesar error de la solicitud
        if (response.body.isNotEmpty) {
          // Imprimir detalles del error en la consola
          print('Error de solicitud: ${response.body}');
        }

        // Mostrar mensaje de error al usuario
        String errorMessage =
            'Error al iniciar sesión. Por favor, inténtalo de nuevo.';
        if (response.statusCode == 401) {
          errorMessage =
              'Usuario o contraseña incorrectos. Por favor, inténtalo de nuevo.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
        ));
      }
    } catch (e) {
      // Procesar errores de red
      print('Error de red: $e');

      // Mostrar mensaje de error al usuario
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Error de red. Por favor, verifica tu conexión e inténtalo de nuevo.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        // permite colocar elementos en orden, uno encima del otro
        child: Stack(
          children: [
            Column(
              // alinear vertical y horizontal
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logoGS.png',
                    width: 250, // Ajusta el tamaño de la imagen
                  ),
                ),
                // const Icon(
                //   Icons.fitness_center,
                //   size: 50,
                //   color: Colors.orange,
                // ),
                // const Text(
                //   'Gym System',
                //   style: TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                const SizedBox(height: 150),
                Form(
                  key: _formLogin,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                          ),
                          labelText: 'Correo',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        textAlign: TextAlign.center,
                        validator: (value) {
                          print("Validando correo ingresado: $value");
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su usuario';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          correo = value!;
                        },
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.password,
                          ),
                          labelText: 'Contraseña',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        textAlign: TextAlign.center,
                        validator: (value) {
                          print("Validando contrasena: $value");
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su contrasena';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          password = value!;
                        },
                      ),

                      const SizedBox(
                        height: 60,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          //realizar validacion cuando se le da al boton
                          if (_formLogin.currentState!.validate()) {
                            _formLogin.currentState!.save();
                            acceder(correo, password);
                          }
                          print('Correo Enviado $correo');
                          print('PW Enviada $password');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 248, 124, 57),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Acceder',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      //Detectar un toque en el texto y al dar clic redirecciona
                      // GestureDetector(
                      //   onTap: () {
                      //     final route = MaterialPageRoute(
                      //       builder: (context) => const Registrar(),
                      //     );
                      //     Navigator.push(context, route);
                      //   },
                      //   child: const Text(
                      //     '¿No tienes cuenta? Regístrate aquí',
                      //     style: TextStyle(
                      //       color: Colors.blue,
                      //       fontSize: 16,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

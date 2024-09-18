import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gym_system/screens/login_screen.dart';
import 'package:http/http.dart' as http;

class Http {
  static String url =
      "http://localhost:3000/api/usuarios"; // Actualiza la URL con tu endpoint correcto
  static postUsuario(Map usuario) async {
    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(usuario),
      );
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        print(data);
        // Asignar rol al usuario
        await assignRole(data['IdUsuario'], 3); // 3 es el idRol para cliente
      } else {
        print('Fallo al insertar los datos');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  static assignRole(int idUsuario, int idRol) async {
    try {
      final res = await http.post(
        Uri.parse(
            "http://192.168.1.100:3000/api/assign-role"), // Actualiza la URL con tu endpoint correcto
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({"idUsuario": idUsuario, "idRol": idRol}),
      );
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body.toString());
        print('Rol asignado correctamente: $data');
      } else {
        print('Fallo al asignar el rol');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

class Registrar extends StatefulWidget {
  const Registrar({Key? key}) : super(key: key);

  @override
  State<Registrar> createState() => _RegistrarState();
}

class _RegistrarState extends State<Registrar> {
  final GlobalKey<FormState> _formRegistro = GlobalKey<FormState>();
  String nombres = '';
  String apellidos = '';
  String tipoDocumento = '';
  String documento = '';
  String correo = '';
  String telefono = '';
  String fechaNacimiento = '';
  String direccion = '';
  String genero = '';
  String password = '';
  String confirmarPassword = '';
  bool terminosAceptados = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Registrar Usuario'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formRegistro,
            child: ListView(
              children: [
                TextFormField(
                  decoration: const InputDecoration(hintText: "Nombres"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese sus nombres';
                    }
                    RegExp regExp = RegExp(r'^[a-zA-Z\s]+$');
                    if (!regExp.hasMatch(value)) {
                      return 'El nombre solo puede contener letras y espacios';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    nombres = value!;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(hintText: "Apellidos"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese sus apellidos';
                    }
                    RegExp regExp = RegExp(r'^[a-zA-Z\s]+$');
                    if (!regExp.hasMatch(value)) {
                      return 'Los apellidos solo pueden contener letras y espacios';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    apellidos = value!;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(hintText: "Tipo de Documento"),
                  items: [
                    DropdownMenuItem(
                        value: "Cedula", child: Text("Cédula de Ciudadanía")),
                    DropdownMenuItem(
                        value: "Pasaporte", child: Text("Pasaporte")),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione el tipo de documento';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      tipoDocumento = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(hintText: "Documento"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su documento';
                    }
                    if (!value.contains(RegExp(r'^[0-9]*$'))) {
                      return 'El documento debe contener solo números';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    documento = value!;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(hintText: "Correo"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su correo';
                    }
                    RegExp emailRegExp =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegExp.hasMatch(value)) {
                      return 'Ingrese un correo electrónico válido';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    correo = value!;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(hintText: "Teléfono"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su teléfono';
                    }
                    RegExp regExp = RegExp(r'^\d{10}$');
                    if (!regExp.hasMatch(value)) {
                      return 'El teléfono debe contener 10 dígitos numéricos';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    telefono = value!;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration:
                      const InputDecoration(hintText: "Fecha de Nacimiento"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su fecha de nacimiento';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    fechaNacimiento = value!;
                  },
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(hintText: "Dirección"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese su dirección';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    direccion = value!;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(hintText: "Género"),
                  items: [
                    DropdownMenuItem(
                        value: "Masculino", child: Text("Masculino")),
                    DropdownMenuItem(
                        value: "Femenino", child: Text("Femenino")),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione su género';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      genero = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(hintText: "Contraseña"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una contraseña';
                    }
                    if (value.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'La contraseña debe contener al menos una mayúscula';
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'La contraseña debe contener al menos un número';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    password = value!;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  obscureText: true,
                  decoration:
                      const InputDecoration(hintText: "Confirmar Contraseña"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirme su contraseña';
                    }
                    if (value != password) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    confirmarPassword = value!;
                  },
                ),
                const SizedBox(height: 10),
                CheckboxListTile(
                  title: const Text("Aceptar términos y condiciones"),
                  value: terminosAceptados,
                  onChanged: (value) {
                    setState(() {
                      terminosAceptados = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formRegistro.currentState!.validate()) {
                      _formRegistro.currentState!.save();
                      Map usuario = {
                        'nombres': nombres,
                        'apellidos': apellidos,
                        'tipoDocumento': tipoDocumento,
                        'documento': documento,
                        'correo': correo,
                        'telefono': telefono,
                        'fechaNacimiento': fechaNacimiento,
                        'direccion': direccion,
                        'genero': genero,
                        'password': password,
                      };
                      Http.postUsuario(usuario);
                    }
                  },
                  child: const Text('Registrar'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes una cuenta?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text('Iniciar sesión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

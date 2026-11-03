import 'package:flutter/material.dart';
import '../servicios/datos_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

// Pantalla 2: Registro de Usuario (RegistroPage)
// Almacena en la base de datos local (SQLite, tabla 'usuarios'): usuario, nombre, apellidos, email, contraseña y fecha_creacion
class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  // Controladores de texto para los datos exigidos en la base de datos
  final _usuarioCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _datos = DatosService();

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  // Lógica de Registro e Inserción en la Tabla 'usuarios' de SQLite
  Future<void> _registrar() async {
    final usuario = _usuarioCtrl.text.trim();
    final nombre = _nombreCtrl.text.trim();
    final apellidos = _apellidosCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    // Validación de campos vacíos
    if (usuario.isEmpty || nombre.isEmpty || apellidos.isEmpty || email.isEmpty || password.isEmpty) {
      _mensaje('Rellena todos los campos obligatorios');
      return;
    }

    // Registro en la base de datos SQLite a través del servicio
    final exito = await _datos.registrarUsuario(
      usuario: usuario,
      nombre: nombre,
      apellidos: apellidos,
      email: email,
      password: password,
      rol: 'usuario',
    );

    if (!mounted) return;

    if (exito) {
      _mensaje('Usuario registrado correctamente en la base de datos');
      Navigator.pop(context); // Vuelve a la pantalla de Login
    } else {
      _mensaje('El nombre de usuario ya está registrado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Campos requeridos por el enunciado para la tabla 'usuarios' utilizando CampoTextoApp
            CampoTextoApp(etiqueta: 'Usuario', controller: _usuarioCtrl),
            CampoTextoApp(etiqueta: 'Nombre', controller: _nombreCtrl),
            CampoTextoApp(etiqueta: 'Apellidos', controller: _apellidosCtrl),
            CampoTextoApp(etiqueta: 'Correo electrónico (Email)', controller: _emailCtrl),
            CampoTextoApp(
              etiqueta: 'Contraseña',
              controller: _passwordCtrl,
              ocultarTexto: true, // Contraseña oculta
            ),
            const SizedBox(height: 16),
            // Reutilización de BotonPrincipal
            BotonPrincipal(texto: 'Registrarse', onPressed: _registrar),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('¿Ya tienes cuenta? Inicia sesión'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../modelos/usuario.dart';
import '../servicios/datos_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _nombreCtrl = TextEditingController();
  final _usuarioCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _datos = DatosService();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _usuarioCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  void _registrar() {
    if (_nombreCtrl.text.isEmpty ||
        _usuarioCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty) {
      _mensaje('Rellena todos los campos');
      return;
    }

    final nuevoUsuario = Usuario(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nombreCtrl.text.trim(),
      usuario: _usuarioCtrl.text.trim(),
      password: _passwordCtrl.text,
      fechaCreacion: DateTime.now(), // Asignada automáticamente
      esAdmin: false,
    );

    final exito = _datos.registrarUsuario(nuevoUsuario);

    if (exito) {
      _mensaje('Usuario registrado correctamente');
      Navigator.pop(context);
    } else {
      _mensaje('El nombre de usuario ya existe');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CampoTextoApp(etiqueta: 'Nombre completo', controller: _nombreCtrl),
            CampoTextoApp(etiqueta: 'Usuario', controller: _usuarioCtrl),
            CampoTextoApp(
              etiqueta: 'Contraseña',
              controller: _passwordCtrl,
              ocultarTexto: true,
            ),
            const SizedBox(height: 12),
            BotonPrincipal(texto: 'Registrarse', onPressed: _registrar),
            const SizedBox(height: 12),
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

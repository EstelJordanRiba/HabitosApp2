import 'package:flutter/material.dart';
import '../servicios/datos_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import 'registro_page.dart';
import 'habitos_page.dart';

// Pantalla 1: Inicio de Sesión (LoginPage)
// Valida el usuario y contraseña consultando la base de datos local SQLite y guarda la sesión en SharedPreferences
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usuarioCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _datos = DatosService();

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  // Acceso asíncrono consultando SQLite y SharedPreferences
  Future<void> _acceder() async {
    final usuario = _usuarioCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (usuario.isEmpty || password.isEmpty) {
      _mensaje('Introduce usuario y contraseña');
      return;
    }

    // Consulta en la base de datos local
    final u = await _datos.login(usuario, password);

    if (u == null) {
      _mensaje('Usuario o contraseña incorrectos');
      return;
    }

    // Entra a la lista de hábitos y guarda la sesión
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HabitosPage(usuario: u)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HábitosApp')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.task_alt,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            // Reutilización de CampoTextoApp
            CampoTextoApp(etiqueta: 'Usuario', controller: _usuarioCtrl),
            CampoTextoApp(
              etiqueta: 'Contraseña',
              controller: _passwordCtrl,
              ocultarTexto: true,
            ),
            const SizedBox(height: 12),
            // Reutilización de BotonPrincipal
            BotonPrincipal(texto: 'Iniciar sesión', onPressed: _acceder),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegistroPage()),
              ),
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../modelos/usuario.dart';
import '../servicios/datos_service.dart';

/// PANTALLA: AjustesScreen
/// Ubicación: lib/pantallas/ajustes_screen.dart
/// Permite configurar el Tema Claro/Oscuro (bool), Tamaño de letra (double con Slider),
/// Ocultar completados (bool) y el botón para Borrar todos los datos.
/// Los ajustes se guardan en memoria en DatosService.
class AjustesScreen extends StatefulWidget {
  final Usuario usuario;
  final VoidCallback onAppSettingsChanged;
  final VoidCallback onResetApp;

  const AjustesScreen({
    super.key,
    required this.usuario,
    required this.onAppSettingsChanged,
    required this.onResetApp,
  });

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final DatosService _datos = DatosService();

  late bool _isDarkMode;
  late double _tamanoLetra;
  late bool _ocultarCompletados;

  @override
  void initState() {
    super.initState();
    _isDarkMode = _datos.isDarkMode;
    _tamanoLetra = _datos.tamanoLetra;
    _ocultarCompletados = _datos.ocultarCompletados;
  }

  /// Confirma y ejecuta el borrado total de datos
  Future<void> _confirmarBorradoDatos() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Expanded(child: Text('¿Borrar todos los datos?')),
          ],
        ),
        content: const Text(
          'Esta acción eliminará todos los hábitos, usuarios registrados y ajustes. '
              'La aplicación volverá a su estado inicial y se cerrará la sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Borrar todo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      _datos.restablecerDatos();
      if (mounted) {
        widget.onResetApp();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitos = _datos.obtenerHabitos(widget.usuario.id);
    final completadosHoy = habitos.where((h) => h.completadoHoy).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AppHábito - Ajustes'),
        elevation: 2,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Perfil actual
          Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(
                  widget.usuario.esAdmin
                      ? Icons.admin_panel_settings
                      : Icons.person,
                ),
              ),
              title: Text(
                widget.usuario.nombre,
                style: TextStyle(
                  fontSize: _tamanoLetra * 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '@${widget.usuario.usuario} · '
                    '${widget.usuario.esAdmin ? 'Administrador' : 'Usuario'}\n'
                    'Hábitos: ${habitos.length} · Completados hoy: $completadosHoy',
                style: TextStyle(fontSize: _tamanoLetra * 0.85),
              ),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Personalización y Preferencias',
            style: TextStyle(
              fontSize: _tamanoLetra * 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                // Tema Oscuro (bool)
                SwitchListTile(
                  secondary: Icon(
                    _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: _isDarkMode ? Colors.amber : Colors.orange,
                  ),
                  title: Text(
                    'Tema Oscuro',
                    style: TextStyle(fontSize: _tamanoLetra),
                  ),
                  value: _isDarkMode,
                  onChanged: (val) {
                    setState(() => _isDarkMode = val);
                    _datos.isDarkMode = val;
                    widget.onAppSettingsChanged();
                  },
                ),
                const Divider(height: 1),

                // Ocultar completados (bool)
                SwitchListTile(
                  secondary: const Icon(Icons.visibility_off, color: Colors.blue),
                  title: Text(
                    'Ocultar hábitos completados hoy',
                    style: TextStyle(fontSize: _tamanoLetra),
                  ),
                  value: _ocultarCompletados,
                  onChanged: (val) {
                    setState(() => _ocultarCompletados = val);
                    _datos.ocultarCompletados = val;
                    widget.onAppSettingsChanged();
                  },
                ),
                const Divider(height: 1),

                // Tamaño de letra con Slider (double)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.text_fields, color: Colors.teal),
                              const SizedBox(width: 12),
                              Text(
                                'Tamaño de letra',
                                style: TextStyle(fontSize: _tamanoLetra),
                              ),
                            ],
                          ),
                          Text(
                            '${_tamanoLetra.toInt()} px',
                            style: TextStyle(
                              fontSize: _tamanoLetra * 0.9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _tamanoLetra,
                        min: 12.0,
                        max: 24.0,
                        divisions: 12,
                        label: '${_tamanoLetra.toInt()} px',
                        onChanged: (val) {
                          setState(() => _tamanoLetra = val);
                        },
                        onChangeEnd: (val) {
                          _datos.tamanoLetra = val;
                          widget.onAppSettingsChanged();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // BORRAR TODOS LOS DATOS
          Card(
            color: Colors.red.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.red.shade200),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red, size: 32),
              title: const Text(
                'Borrar todos los datos',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Restablece la app como recién instalada',
                style: TextStyle(color: Colors.redAccent),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _confirmarBorradoDatos,
                child: const Text('Borrar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
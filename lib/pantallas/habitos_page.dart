import 'package:flutter/material.dart';
import '../modelos/usuario.dart';
import '../modelos/habito.dart';
import '../servicios/datos_service.dart';
import '../widgets/tarjeta_habito.dart';
import 'editar_habito_page.dart';
import 'estadisticas_page.dart';
import 'administracion_page.dart';
import 'login_page.dart';

class HabitosPage extends StatefulWidget {
  final Usuario usuario;

  const HabitosPage({super.key, required this.usuario});

  @override
  State<HabitosPage> createState() => _HabitosPageState();
}

class _HabitosPageState extends State<HabitosPage> {
  final _datos = DatosService();
  List<Habito> _habitos = [];

  @override
  void initState() {
    super.initState();
    _cargarHabitos();
  }

  Future<void> _cargarHabitos() async {
    setState(() {
      _habitos = _datos.obtenerHabitos(widget.usuario.id);
    });
  }

  void _completar(Habito habito) {
    _datos.completarHabito(habito);
    _cargarHabitos();
  }

  Future<void> _abrirEditor(Habito? habito) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarHabitoPage(
          usuario: widget.usuario,
          habito: habito,
        ),
      ),
    );
    if (guardado == true) await _cargarHabitos();
  }

  Future<void> _confirmarEliminar(Habito habito) async {
    final aceptado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar hábito'),
        content: Text('¿Seguro que quieres eliminar "${habito.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (aceptado == true) {
      _datos.eliminarHabito(habito.id);
      await _cargarHabitos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Hábitos (${widget.usuario.nombre})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Estadísticas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EstadisticasPage(usuario: widget.usuario),
                ),
              );
            },
          ),
          if (widget.usuario.esAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Administración',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdministracionPage(),
                  ),
                ).then((_) => _cargarHabitos());
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          ),
        ],
      ),
      body: _habitos.isEmpty
          ? const Center(
              child: Text(
                'Todavía no tienes hábitos.\nPulsa + para crear uno.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _habitos.length,
              itemBuilder: (context, i) {
                final h = _habitos[i];
                return TarjetaHabito(
                  nombre: h.nombre,
                  color: h.color,
                  icono: h.icono,
                  completadoHoy: h.completadoHoy,
                  onCompletar: () => _completar(h),
                  onEditar: () => _abrirEditor(h),
                  onEliminar: () => _confirmarEliminar(h),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirEditor(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}

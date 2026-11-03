import 'package:flutter/material.dart';
import '../modelos/usuario.dart';
import '../modelos/habito.dart';
import '../modelos/estadistica.dart';
import '../servicios/datos_service.dart';
import '../widgets/dato_estadistica.dart';

// Pantalla 5: Estadísticas (EstadisticasPage)
// Consulta de la tabla 'estadisticas' en SQLite la racha actual y los días completados de cada hábito
class EstadisticasPage extends StatefulWidget {
  final Usuario usuario;

  const EstadisticasPage({super.key, required this.usuario});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  final _datos = DatosService();
  List<Habito> _habitos = [];
  Map<int, Estadistica> _estadisticas = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    if (widget.usuario.id == null) return;
    final List<Habito> listaHabitos = await _datos.obtenerHabitos(widget.usuario.id!);
    final Map<int, Estadistica> mapEst = {};

    for (var h in listaHabitos) {
      if (h.id != null) {
        final est = await _datos.obtenerEstadistica(h.id!);
        if (est != null) {
          mapEst[h.id!] = est;
        }
      }
    }

    if (mounted) {
      setState(() {
        _habitos = listaHabitos;
        _estadisticas = mapEst;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _habitos.isEmpty
              ? const Center(
                  child: Text(
                    'No hay estadísticas disponibles.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _habitos.length,
                  itemBuilder: (context, i) {
                    final h = _habitos[i];
                    final est = (h.id != null ? _estadisticas[h.id!] : null) ??
                        Estadistica(
                          habitoId: h.id ?? 0,
                          rachaActual: 0,
                          totalDiasCompletados: 0,
                        );

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.nombre,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: h.color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Fila con los componentes reutilizables DatoEstadistica
                            Row(
                              children: [
                                DatoEstadistica(
                                  etiqueta: 'Racha actual',
                                  valor: '${est.rachaActual} días',
                                  icono: Icons.local_fire_department,
                                  color: h.color,
                                ),
                                DatoEstadistica(
                                  etiqueta: 'Días completados',
                                  valor: '${est.totalDiasCompletados}',
                                  icono: Icons.check_circle,
                                  color: h.color,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

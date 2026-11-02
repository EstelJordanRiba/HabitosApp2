import 'package:flutter/material.dart';
import '../modelos/usuario.dart';
import '../modelos/habito.dart';
import '../servicios/datos_service.dart';
import '../widgets/dato_estadistica.dart';

class EstadisticasPage extends StatelessWidget {
  final Usuario usuario;

  const EstadisticasPage({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final habitos = DatosService().obtenerHabitos(usuario.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: habitos.isEmpty
          ? const Center(
              child: Text(
                'No hay estadísticas disponibles.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: habitos.length,
              itemBuilder: (context, i) {
                final h = habitos[i];
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
                        Row(
                          children: [
                            DatoEstadistica(
                              etiqueta: 'Racha actual',
                              valor: '${h.racha} días',
                              icono: Icons.local_fire_department,
                              color: h.color,
                            ),
                            DatoEstadistica(
                              etiqueta: 'Días completados',
                              valor: '${h.total}',
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

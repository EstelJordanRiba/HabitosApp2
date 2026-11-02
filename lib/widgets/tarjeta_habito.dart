import 'package:flutter/material.dart';

class TarjetaHabito extends StatelessWidget {
  final String nombre;
  final Color color;
  final bool completadoHoy;
  final IconData icono;
  final VoidCallback onCompletar;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const TarjetaHabito({
    super.key,
    required this.nombre,
    required this.color,
    required this.completadoHoy,
    this.icono = Icons.star,
    required this.onCompletar,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 2),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icono, color: Colors.white),
        ),
        title: Text(
          nombre,
          style: TextStyle(
            decoration: completadoHoy ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(completadoHoy ? 'Completado hoy' : 'Pendiente'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                completadoHoy ? Icons.check_circle : Icons.radio_button_unchecked,
                color: completadoHoy ? Colors.green : Colors.grey,
              ),
              tooltip: 'Completar',
              onPressed: onCompletar,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar',
              onPressed: onEditar,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Eliminar',
              onPressed: onEliminar,
            ),
          ],
        ),
      ),
    );
  }
}

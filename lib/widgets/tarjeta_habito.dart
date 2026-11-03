import 'package:flutter/material.dart';


// COMPONENTE REUTILIZABLE 3: TarjetaHabito
// Hereda de StatelessWidget. Presenta gráficamente un hábito dentro de la lista.
// Muestra el color identificativo en el borde y avatar, tachado si está completado,
// estado "Completado hoy / Pendiente" y botones para marcar completado, editar y eliminar.


class TarjetaHabito extends StatelessWidget {
  final String nombre;            // Nombre del hábito
  final Color color;              // Color de identificación personalizado
  final bool completadoHoy;       // Estado para el día de hoy (true/false)
  final IconData icono;           // Icono gráfico asignado
  final VoidCallback onCompletar; // Callback al pulsar el botón de completar/desmarcar
  final VoidCallback onEditar;    // Callback para abrir el formulario de edición
  final VoidCallback onEliminar;  // Callback para iniciar el flujo de eliminación

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
        // Borde exterior con el color del hábito para destacarlo
        side: BorderSide(color: color, width: 2),
      ),
      child: ListTile(
        // Avatar circular con fondo del color del hábito e icono
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icono, color: Colors.white),
        ),
        // Título del hábito: Se tacha con lineThrough si se completó hoy
        title: Text(
          nombre,
          style: TextStyle(
            decoration: completadoHoy ? TextDecoration.lineThrough : null,
          ),
        ),
        // Texto informativo del estado del hábito
        subtitle: Text(completadoHoy ? 'Completado hoy' : 'Pendiente'),
        // Fila de botones de acción en el lateral derecho (trailing)
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón 1: Alternar estado completado/pendiente
            IconButton(
              icon: Icon(
                completadoHoy ? Icons.check_circle : Icons.radio_button_unchecked,
                color: completadoHoy ? Colors.green : Colors.grey,
              ),
              tooltip: 'Completar',
              onPressed: onCompletar,
            ),
            // Botón 2: Abrir editor
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar',
              onPressed: onEditar,
            ),
            // Botón 3: Eliminar hábito
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

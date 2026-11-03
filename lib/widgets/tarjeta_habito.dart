import 'package:flutter/material.dart';

// Componente Reutilizable 3: TarjetaHabito
// Hereda de StatelessWidget. Muestra la representación gráfica de un hábito en la lista (nombre, color, estado y botones de acción).
class TarjetaHabito extends StatelessWidget {
  final String nombre;            // Nombre del hábito a mostrar
  final Color color;              // Color identificativo asignado al hábito
  final bool completadoHoy;       // Estado del hábito para el día de hoy (true = realizado, false = pendiente)
  final IconData icono;           // Icono gráfico (con valor por defecto Icons.star)
  final VoidCallback onCompletar; // Callback para marcar o desmarcar el hábito como completado
  final VoidCallback onEditar;    // Callback para abrir la pantalla de edición del hábito
  final VoidCallback onEliminar;  // Callback para iniciar el proceso de eliminación del hábito

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
        // Borde exterior con el color propio del hábito para identificarlo fácilmente
        side: BorderSide(color: color, width: 2),
      ),
      child: ListTile(
        // Avatar circular con el fondo del color del hábito y su icono representativo
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icono, color: Colors.white),
        ),
        // Título del hábito: Se tacha visualmente (lineThrough) si ya se ha completado hoy
        title: Text(
          nombre,
          style: TextStyle(
            decoration: completadoHoy ? TextDecoration.lineThrough : null,
          ),
        ),
        // Subtítulo con el texto informativo sobre si está completado o pendiente
        subtitle: Text(completadoHoy ? 'Completado hoy' : 'Pendiente'),
        // Botones de acción situados en el extremo derecho (trailing)
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Ajusta el tamaño de la fila al contenido de los botones
          children: [
            // Botón 1: Marcar como completado/pendiente
            IconButton(
              icon: Icon(
                completadoHoy ? Icons.check_circle : Icons.radio_button_unchecked,
                color: completadoHoy ? Colors.green : Colors.grey,
              ),
              tooltip: 'Completar',
              onPressed: onCompletar,
            ),
            // Botón 2: Editar hábito
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

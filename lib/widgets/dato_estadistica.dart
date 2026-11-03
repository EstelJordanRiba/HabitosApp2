import 'package:flutter/material.dart';


// COMPONENTE REUTILIZABLE 4: DatoEstadistica
// Hereda de StatelessWidget. Diseñado para mostrar métricas (racha actual y días completados)
// con un valor grande, icono y etiqueta centrada. Al usar Expanded, debe colocarse dentro de un Row.


class DatoEstadistica extends StatelessWidget {
  final String etiqueta; // Nombre de la métrica (ej. "Racha actual", "Días completados")
  final String valor;    // Valor numérico o formateado (ej. "5 días", "12")
  final IconData icono;  // Icono visual ilutrativo
  final Color color;     // Color asignado para la tarjeta y el texto destacado

  const DatoEstadistica({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.icono,
    this.color = Colors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // Distribuye el espacio equitativamente en la fila (Row)
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12), // Fondo suave con opacidad del color
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 28), // Icono destacado
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(etiqueta, textAlign: TextAlign.center), // Etiqueta descriptiva
          ],
        ),
      ),
    );
  }
}

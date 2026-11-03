import 'package:flutter/material.dart';

// Componente Reutilizable 4: DatoEstadistica
// Hereda de StatelessWidget. Muestra un bloque con un icono, valor grande y una etiqueta (ej. racha o días completados).
// Importante: Al incluir un widget Expanded como raíz, debe colocarse siempre dentro de un contenedor flexible como Row.
class DatoEstadistica extends StatelessWidget {
  final String etiqueta; // Texto descriptivo de la métrica (ej. "Racha actual", "Días completados")
  final String valor;    // Valor o resultado a destacar (ej. "5 días", "12")
  final IconData icono;  // Icono visual ilustrativo
  final Color color;     // Color del texto, del icono y del fondo traslúcido (por defecto Teal)

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
      // Distribuye equitativamente el espacio horizontal en una Fila (Row)
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12), // Fondo suave con opacidad del color recibido
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 28), // Icono principal de la métrica
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(etiqueta, textAlign: TextAlign.center), // Etiqueta descriptiva centrada
          ],
        ),
      ),
    );
  }
}

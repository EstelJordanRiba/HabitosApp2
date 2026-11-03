import 'package:flutter/material.dart';


// COMPONENTE REUTILIZABLE 2: BotonPrincipal
// Hereda de StatelessWidget. Establece el diseño y estilo estandarizado para
// todos los botones de acción principal en la app (ancho completo, padding y tamaño de texto).

class BotonPrincipal extends StatelessWidget {
  final String texto;           // Texto que se mostrará dentro del botón
  final VoidCallback onPressed; // Acción (función callback) ejecutada al pulsar el botón

  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        width: double.infinity, // Hace que el botón ocupe el 100% del ancho disponible
        child: ElevatedButton(
          onPressed: onPressed, // Delegación de la acción a la pantalla invocadora
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16), // Altura táctil cómoda
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Redondeo de bordes estandarizado
            ),
          ),
          child: Text(texto, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

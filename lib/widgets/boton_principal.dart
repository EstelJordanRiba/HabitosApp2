import 'package:flutter/material.dart';

// Componente Reutilizable 2: BotonPrincipal
// Hereda de StatelessWidget. Define el diseño y comportamiento estándar para los botones principales de la aplicación.
class BotonPrincipal extends StatelessWidget {
  final String texto;           // Texto visible dentro del botón (ej. "Iniciar sesión", "Registrarse", "Guardar")
  final VoidCallback onPressed; // Callback (función recibida) que ejecutará la acción definida por la pantalla al pulsarlo

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
        width: double.infinity, // Ocupa todo el ancho disponible del contenedor padre
        child: ElevatedButton(
          onPressed: onPressed, // Ejecuta la acción recibida sin guardar estado en el widget
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16), // Relleno vertical para mayor comodidad táctil
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Bordes redondeados manteniendo coherencia con CampoTextoApp
            ),
          ),
          child: Text(texto, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

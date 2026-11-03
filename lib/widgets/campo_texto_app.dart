import 'package:flutter/material.dart';


// COMPONENTE REUTILIZABLE 1: CampoTextoApp
// Hereda de StatelessWidget (sin estado propio). Garantiza un diseño de TextField
// unificado para toda la aplicación (login, registro, crear/editar hábito y administración).


class CampoTextoApp extends StatelessWidget {
  final String etiqueta;                 // Texto visible de la etiqueta (ej. "Usuario", "Contraseña", "Email")
  final TextEditingController controller; // Controlador asignado y gestionado por la pantalla padre
  final bool ocultarTexto;                // Booleano opcional (default false) para ocultar texto en contraseñas

  const CampoTextoApp({
    super.key,
    required this.etiqueta,
    required this.controller,
    this.ocultarTexto = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Separación vertical uniforme entre campos
      child: TextField(
        controller: controller,
        obscureText: ocultarTexto, // Oculta caracteres si es true
        decoration: InputDecoration(
          labelText: etiqueta,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados estándares en toda la app
          ),
        ),
      ),
    );
  }
}

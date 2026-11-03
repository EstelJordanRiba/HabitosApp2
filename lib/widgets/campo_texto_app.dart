import 'package:flutter/material.dart';

// Componente Reutilizable 1: CampoTextoApp
// Hereda de StatelessWidget (sin estado propio). Su única responsabilidad es pintar un campo de texto normal o con contraseña oculta.
class CampoTextoApp extends StatelessWidget {
  final String etiqueta;                 // Texto que se muestra como etiqueta/hint del campo (ej. "Usuario", "Contraseña")
  final TextEditingController controller; // Controlador de texto creado y gestionado desde la pantalla llamante
  final bool ocultarTexto;                // Booleano para ocultar los caracteres (usado en contraseñas), por defecto es false

  const CampoTextoApp({
    super.key,
    required this.etiqueta,
    required this.controller,
    this.ocultarTexto = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Margen vertical uniforme para separar campos
      child: TextField(
        controller: controller,
        obscureText: ocultarTexto, // Oculta los caracteres con puntos si es true
        decoration: InputDecoration(
          labelText: etiqueta,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Bordes redondeados estandarizados para toda la app
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';


// FUNCIÓN: Modelo de Datos para la entidad 'Hábito'
// Representa la tabla 'habitos' en SQLite. Almacena la relación con el usuario (clave foránea),
// nombre, color, icono y la lista de fechas completadas para calcular rachas automáticamente.


class Habito {
  final int? id;                       // Clave Primaria Autoincremental en SQLite
  final int usuarioId;                 // Clave Foránea apuntando a usuarios.id
  final String nombre;                 // Nombre descriptivo del hábito (ej. "Hacer ejercicio")
  final Color color;                   // Color representativo del hábito
  final IconData icono;                // Icono gráfico de Material Icons
  final List<String> fechasCompletado; // Historial de fechas completadas en formato "YYYY-MM-DD"
  final bool completadoHoy;            // Indicador de si se ha marcado completado hoy

  Habito({
    this.id,
    required this.usuarioId,
    required this.nombre,
    required this.color,
    this.icono = Icons.star,
    this.fechasCompletado = const [],
    this.completadoHoy = false,
  });

  // Convierte el objeto Hábito a Mapa para operaciones de inserción y actualización en SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'usuario_id': usuarioId,
      'nombre': nombre,
      'color': color.value,                              // Guarda el entero ARGB del color
      'icono': icono.codePoint,                           // Guarda el entero codePoint de MaterialIcons
      'fechas_completado': jsonEncode(fechasCompletado), // Serializa la lista a una cadena JSON String
      'completado_hoy': completadoHoy ? 1 : 0,           // Guarda 1 (true) o 0 (false)
    };
  }

  // Reconstruye el objeto Hábito desde el Mapa devuelto por una consulta en SQLite
  factory Habito.fromMap(Map<String, dynamic> map) {
    List<String> fechas = [];
    if (map['fechas_completado'] != null) {
      try {
        final decoded = jsonDecode(map['fechas_completado']);
        if (decoded is List) {
          fechas = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    return Habito(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
      usuarioId: map['usuario_id'] is int
          ? map['usuario_id']
          : int.parse(map['usuario_id'].toString()),
      nombre: map['nombre'] ?? '',
      color: Color(map['color'] ?? Colors.teal.value),
      icono: map['icono'] != null
          ? IconData(map['icono'], fontFamily: 'MaterialIcons')
          : Icons.star,
      fechasCompletado: fechas,
      // Se determina automáticamente comprobando si la lista incluye la fecha del día actual
      completadoHoy: fechas.contains(DateTime.now().toIso8601String().split('T').first),
    );
  }

  // Clonación inmutable del objeto
  Habito copyWith({
    int? id,
    int? usuarioId,
    String? nombre,
    Color? color,
    IconData? icono,
    List<String>? fechasCompletado,
    bool? completadoHoy,
  }) {
    return Habito(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
      icono: icono ?? this.icono,
      fechasCompletado: fechasCompletado ?? this.fechasCompletado,
      completadoHoy: completadoHoy ?? this.completadoHoy,
    );
  }
}

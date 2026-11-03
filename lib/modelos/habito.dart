import 'dart:convert';
import 'package:flutter/material.dart';

// Modelo de Datos: Hábito
// Representa la tabla 'habitos' en la base de datos local SQLite
class Habito {
  final int? id;                       // Identificador único del hábito (Clave primaria autoincremental)
  final int usuarioId;                 // ID del usuario propietario (Clave foránea hacia usuarios.id)
  final String nombre;                 // Nombre descriptivo del hábito
  final Color color;                   // Color representativo del hábito
  final IconData icono;                // Icono visual del hábito
  final List<String> fechasCompletado; // Fechas en las que el hábito ha sido completado
  final bool completadoHoy;            // Indicador de si se ha completado en el día de hoy

  Habito({
    this.id,
    required this.usuarioId,
    required this.nombre,
    required this.color,
    this.icono = Icons.star,
    this.fechasCompletado = const [],
    this.completadoHoy = false,
  });

  // Convierte el objeto Hábito a un Mapa para SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'usuario_id': usuarioId,
      'nombre': nombre,
      'color': color.value,
      'icono': icono.codePoint,
      'fechas_completado': jsonEncode(fechasCompletado), // Almacena la lista de fechas como JSON String
      'completado_hoy': completadoHoy ? 1 : 0,           // Guarda 1 para true y 0 para false en SQLite
    };
  }

  // Construye un Hábito desde el Mapa devuelto por SQLite
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
      completadoHoy: (map['completado_hoy'] ?? 0) == 1,
    );
  }

  // Copia inmutable del hábito
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

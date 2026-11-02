import 'package:flutter/material.dart';

class Habito {
  final String id;
  final String usuarioId;
  final String nombre;
  final Color color;
  final IconData icono;
  final bool completadoHoy;
  final int racha;
  final int total;

  Habito({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.color,
    this.icono = Icons.star,
    this.completadoHoy = false,
    this.racha = 0,
    this.total = 0,
  });

  Habito copyWith({
    String? id,
    String? usuarioId,
    String? nombre,
    Color? color,
    IconData? icono,
    bool? completadoHoy,
    int? racha,
    int? total,
  }) {
    return Habito(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
      icono: icono ?? this.icono,
      completadoHoy: completadoHoy ?? this.completadoHoy,
      racha: racha ?? this.racha,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'nombre': nombre,
      'color': color.value,
      'icono': icono.codePoint,
      'completadoHoy': completadoHoy,
      'racha': racha,
      'total': total,
    };
  }

  factory Habito.fromMap(Map<String, dynamic> map) {
    return Habito(
      id: map['id'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      nombre: map['nombre'] ?? '',
      color: Color(map['color'] ?? Colors.teal.value),
      icono: map['icono'] != null
          ? IconData(map['icono'], fontFamily: 'MaterialIcons')
          : Icons.star,
      completadoHoy: map['completadoHoy'] ?? false,
      racha: map['racha'] ?? 0,
      total: map['total'] ?? 0,
    );
  }
}

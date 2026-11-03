
// Representa la tabla 'estadisticas' en la base de datos local SQLite.
// Guarda el cálculo de racha de días consecutivos y el total de días completados
// asociado a cada hábito mediante la clave foránea habito_id.


class Estadistica {
  final int? id;                    // Clave Primaria Autoincremental en SQLite
  final int habitoId;               // Clave Foránea hacia habitos.id
  final int rachaActual;            // Racha de días consecutivos cumplidos
  final int totalDiasCompletados;   // Total acumulado de días en que se ha completado el hábito

  Estadistica({
    this.id,
    required this.habitoId,
    required this.rachaActual,
    required this.totalDiasCompletados,
  });

  // Mapea la instancia de Estadística a Mapa para SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'habito_id': habitoId,
      'racha_actual': rachaActual,
      'total_dias_completados': totalDiasCompletados,
    };
  }

  // Reconstruye el objeto Estadística a partir del Mapa leído en SQLite
  factory Estadistica.fromMap(Map<String, dynamic> map) {
    return Estadistica(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
      habitoId: map['habito_id'] is int
          ? map['habito_id']
          : int.parse(map['habito_id'].toString()),
      rachaActual: map['racha_actual'] ?? 0,
      totalDiasCompletados: map['total_dias_completados'] ?? 0,
    );
  }

  // Clonación inmutable con actualización de campos
  Estadistica copyWith({
    int? id,
    int? habitoId,
    int? rachaActual,
    int? totalDiasCompletados,
  }) {
    return Estadistica(
      id: id ?? this.id,
      habitoId: habitoId ?? this.habitoId,
      rachaActual: rachaActual ?? this.rachaActual,
      totalDiasCompletados: totalDiasCompletados ?? this.totalDiasCompletados,
    );
  }
}

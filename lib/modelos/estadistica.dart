// Modelo de Datos: Estadística
// Representa la tabla 'estadisticas' en la base de datos local SQLite

class Estadistica {
  final int? id;                    // Clave primaria autoincremental
  final int habitoId;               // ID del hábito asociado (Clave foránea hacia habitos.id)
  final int rachaActual;            // Racha actual en días consecutivos
  final int totalDiasCompletados;   // Acumulado total de días completados

  Estadistica({
    this.id,
    required this.habitoId,
    required this.rachaActual,
    required this.totalDiasCompletados,
  });

  // Convierte el objeto Estadística a un Mapa para SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'habito_id': habitoId,
      'racha_actual': rachaActual,
      'total_dias_completados': totalDiasCompletados,
    };
  }

  // Reconstruye el objeto Estadística desde la fila devuelta por SQLite
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

  // Copia inmutable del objeto Estadística
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

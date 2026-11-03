
// FUNCIÓN: Modelo de Datos para la entidad 'Usuario'
// Representa la estructura de la tabla 'usuarios' en la base de datos local SQLite.
// Incluye métodos para mapear datos desde/hacia Mapa (JSON / Filas de SQLite).


class Usuario {
  final int? id;               // Clave Primaria Autoincremental en SQLite (null antes de insertarse)
  final String usuario;        // Nombre de usuario único para inicio de sesión (credencial)
  final String nombre;         // Nombre de pila del usuario
  final String apellidos;      // Apellidos del usuario
  final String email;          // Correo electrónico
  final String password;       // Contraseña de acceso
  final DateTime fechaCreacion;// Fecha y hora de alta asignada automáticamente
  final String rol;            // Rol en el sistema: 'administrador' o 'usuario'

  // Constructor con parámetros nombrados y rol por defecto 'usuario'
  Usuario({
    this.id,
    required this.usuario,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.password,
    required this.fechaCreacion,
    this.rol = 'usuario',
  });

  // Getter auxiliar para evaluar rápidamente si el usuario tiene privilegios de administrador
  bool get esAdmin => rol == 'administrador';

  // Convierte el objeto Usuario a un Mapa (clave-valor) para insertarlo o actualizarlo en SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'usuario': usuario,
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'password': password,
      'fecha_creacion': fechaCreacion.toIso8601String(), // Convierte DateTime a cadena ISO 8601 para SQLite
      'rol': rol,
    };
  }

  // Constructor de fábrica (factory) para reconstruir el objeto Usuario desde un Mapa leido de SQLite
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
      usuario: map['usuario'] ?? '',
      nombre: map['nombre'] ?? '',
      apellidos: map['apellidos'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'])
          : DateTime.now(),
      rol: map['rol'] ?? 'usuario',
    );
  }

  // Método copyWith para obtener una copia inmutable del objeto modificando campos específicos
  Usuario copyWith({s
    int? id,
    String? usuario,
    String? nombre,
    String? apellidos,
    String? email,
    String? password,
    DateTime? fechaCreacion,
    String? rol,
  }) {
    return Usuario(
      id: id ?? this.id,
      usuario: usuario ?? this.usuario,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      email: email ?? this.email,
      password: password ?? this.password,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      rol: rol ?? this.rol,
    );
  }
}

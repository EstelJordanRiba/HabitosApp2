// Modelo de Datos: Usuario
// Representa la tabla 'usuarios' en la base de datos local SQLite
class Usuario {
  final int? id;               // Identificador único (Clave primaria autoincremental en SQLite)
  final String usuario;        // Nombre de usuario único para login
  final String nombre;         // Nombre de pila del usuario
  final String apellidos;      // Apellidos del usuario
  final String email;          // Correo electrónico del usuario
  final String password;       // Contraseña de acceso
  final DateTime fechaCreacion;// Fecha de creación de la cuenta (fecha_creacion)
  final String rol;            // Rol del usuario: 'administrador' o 'usuario'

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

  // Comprueba si el usuario tiene rol de administrador
  bool get esAdmin => rol == 'administrador';

  // Convierte el objeto Usuario a un Mapa para insertarlo/actualizarlo en la tabla 'usuarios' de SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'usuario': usuario,
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'password': password,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'rol': rol,
    };
  }

  // Construye un objeto Usuario a partir de la fila leída de la base de datos SQLite
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

  // Copia el objeto cambiando propiedades específicas
  Usuario copyWith({
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

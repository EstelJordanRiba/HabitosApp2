class Usuario {
  final String id;
  final String nombre;
  final String usuario;
  final String password;
  final DateTime fechaCreacion;
  final bool esAdmin;

  Usuario({
    required this.id,
    required this.nombre,
    required this.usuario,
    required this.password,
    required this.fechaCreacion,
    this.esAdmin = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'usuario': usuario,
      'password': password,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'esAdmin': esAdmin,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      usuario: map['usuario'] ?? '',
      password: map['password'] ?? '',
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'])
          : DateTime.now(),
      esAdmin: map['esAdmin'] ?? false,
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/usuario.dart';
import '../modelos/habito.dart';
import '../modelos/estadistica.dart';

// Gestor de Base de Datos SQLite (sqflite) y Preferencias Compartidas (shared_preferences)
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();

  // Obtiene la instancia activa de la base de datos SQLite (creándola si no existe)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa la base de datos creando el archivo habitos_app.db
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'habitos_app.db');

    return await openDatabase(
      path,
      version: 1,
      // Activa las claves foráneas (ON DELETE CASCADE)
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
  }

  // Borra el archivo de la base de datos. Al volver a abrirla se crea de nuevo con los datos de ejemplo
  Future<void> borrarBaseDatos() async {
    final path = join(await getDatabasesPath(), 'habitos_app.db');
    await _database?.close();
    _database = null;
    await deleteDatabase(path);
  }

  // Creación de las 3 tablas requeridas: usuarios, habitos y estadisticas
  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabla 'usuarios'
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT NOT NULL UNIQUE,
        nombre TEXT NOT NULL,
        apellidos TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        fecha_creacion TEXT NOT NULL,
        rol TEXT NOT NULL
      )
    ''');

    // 2. Tabla 'habitos'
    await db.execute('''
      CREATE TABLE habitos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        color INTEGER NOT NULL,
        icono INTEGER NOT NULL,
        fechas_completado TEXT NOT NULL,
        completado_hoy INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
      )
    ''');

    // 3. Tabla 'estadisticas'
    await db.execute('''
      CREATE TABLE estadisticas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habito_id INTEGER NOT NULL UNIQUE,
        racha_actual INTEGER NOT NULL DEFAULT 0,
        total_dias_completados INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (habito_id) REFERENCES habitos (id) ON DELETE CASCADE
      )
    ''');

    // Insertar datos de prueba iniciales (Usuario normal y Administrador)
    await _insertarDatosIniciales(db);
  }

  Future<void> _insertarDatosIniciales(Database db) async {
    final fechaBase = DateTime.now().subtract(const Duration(days: 10)).toIso8601String();

    // Devuelve las fechas (yyyy-MM-dd) de hace n días, para que los datos de ejemplo sean coherentes
    String hace(int dias) =>
        DateTime.now().subtract(Duration(days: dias)).toIso8601String().split('T').first;

    // 1. Usuario Administrador
    final adminId = await db.insert('usuarios', {
      'usuario': 'admin',
      'nombre': 'Administrador',
      'apellidos': 'Sistema',
      'email': 'admin@habitos.com',
      'password': 'admin',
      'fecha_creacion': fechaBase,
      'rol': 'administrador',
    });

    // 2. Usuario Estándar
    final userId = await db.insert('usuarios', {
      'usuario': 'usuario',
      'nombre': 'Usuario',
      'apellidos': 'Estándar',
      'email': 'usuario@habitos.com',
      'password': '1234',
      'fecha_creacion': fechaBase,
      'rol': 'usuario',
    });

    // Hábito 1: completado hoy y los 4 días anteriores -> racha 5, total 5
    final h1Id = await db.insert('habitos', {
      'usuario_id': userId,
      'nombre': 'Hacer Ejercicio',
      'color': Colors.teal.value,
      'icono': Icons.fitness_center.codePoint,
      'fechas_completado': jsonEncode([hace(4), hace(3), hace(2), hace(1), hace(0)]),
      'completado_hoy': 1,
    });
    await db.insert('estadisticas', {
      'habito_id': h1Id,
      'racha_actual': 5,
      'total_dias_completados': 5,
    });

    // Hábito 2: completado los 3 días anteriores, hoy pendiente -> racha 3, total 3
    final h2Id = await db.insert('habitos', {
      'usuario_id': userId,
      'nombre': 'Leer 20 Minutos',
      'color': Colors.orange.value,
      'icono': Icons.menu_book.codePoint,
      'fechas_completado': jsonEncode([hace(3), hace(2), hace(1)]),
      'completado_hoy': 0,
    });
    await db.insert('estadisticas', {
      'habito_id': h2Id,
      'racha_actual': 3,
      'total_dias_completados': 3,
    });

    // Hábito del Administrador: sin completar -> racha 0, total 0
    final hAdminId = await db.insert('habitos', {
      'usuario_id': adminId,
      'nombre': 'Revisar métricas del sistema',
      'color': Colors.purple.value,
      'icono': Icons.star.codePoint,
      'fechas_completado': '[]',
      'completado_hoy': 0,
    });
    await db.insert('estadisticas', {
      'habito_id': hAdminId,
      'racha_actual': 0,
      'total_dias_completados': 0,
    });
  }

  // ==========================================
  // CRUD TABLA: USUARIOS
  // ==========================================

  // C: Crear Usuario
  Future<int> insertUsuario(Usuario usuario) async {
    final db = await database;
    return await db.insert('usuarios', usuario.toMap());
  }

  // R: Consultar todos los Usuarios
  Future<List<Usuario>> getUsuarios() async {
    final db = await database;
    final maps = await db.query('usuarios', orderBy: 'id ASC');
    return maps.map((m) => Usuario.fromMap(m)).toList();
  }

  // R: Consultar Usuario por nombre de usuario (para Login y validación)
  Future<Usuario?> getUsuarioByUsername(String usuario) async {
    final db = await database;
    final maps = await db.query(
      'usuarios',
      where: 'LOWER(usuario) = LOWER(?)',
      whereArgs: [usuario.trim()],
    );
    if (maps.isNotEmpty) return Usuario.fromMap(maps.first);
    return null;
  }

  // R: Consultar Usuario por ID
  Future<Usuario?> getUsuarioById(int id) async {
    final db = await database;
    final maps = await db.query('usuarios', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Usuario.fromMap(maps.first);
    return null;
  }

  // U: Actualizar Usuario
  Future<int> updateUsuario(Usuario usuario) async {
    final db = await database;
    return await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  // D: Eliminar Usuario y sus hábitos/estadísticas asociadas
  Future<int> deleteUsuario(int id) async {
    final db = await database;
    // Eliminamos los hábitos del usuario en cascada
    final habitos = await getHabitosByUsuario(id);
    for (var h in habitos) {
      if (h.id != null) await deleteHabito(h.id!);
    }
    return await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // CRUD TABLA: HÁBITOS
  // ==========================================

  // C: Crear Hábito (y crea automáticamente su registro en la tabla estadísticas)
  Future<int> insertHabito(Habito habito) async {
    final db = await database;
    final habitoId = await db.insert('habitos', habito.toMap());

    // Crear la entrada inicial en la tabla 'estadisticas'
    await db.insert('estadisticas', {
      'habito_id': habitoId,
      'racha_actual': 0,
      'total_dias_completados': 0,
    });

    return habitoId;
  }

  // R: Consultar Hábitos de un usuario específico
  Future<List<Habito>> getHabitosByUsuario(int usuarioId) async {
    final db = await database;
    final maps = await db.query(
      'habitos',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'id ASC',
    );
    return maps.map((m) => Habito.fromMap(m)).toList();
  }

  // R: Consultar TODOS los Hábitos (Rol Administrador)
  Future<List<Habito>> getAllHabitos() async {
    final db = await database;
    final maps = await db.query('habitos', orderBy: 'id ASC');
    return maps.map((m) => Habito.fromMap(m)).toList();
  }

  // U: Actualizar Hábito
  Future<int> updateHabito(Habito habito) async {
    final db = await database;
    return await db.update(
      'habitos',
      habito.toMap(),
      where: 'id = ?',
      whereArgs: [habito.id],
    );
  }

  // D: Eliminar Hábito y su estadística correspondiente
  Future<int> deleteHabito(int id) async {
    final db = await database;
    await db.delete('estadisticas', where: 'habito_id = ?', whereArgs: [id]);
    return await db.delete('habitos', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // CRUD TABLA: ESTADÍSTICAS
  // ==========================================

  // C: Crear Estadística explícitamente
  Future<int> insertEstadistica(Estadistica est) async {
    final db = await database;
    return await db.insert('estadisticas', est.toMap());
  }

  // R: Obtener Estadística por ID de Hábito
  Future<Estadistica?> getEstadisticaByHabito(int habitoId) async {
    final db = await database;
    final maps = await db.query(
      'estadisticas',
      where: 'habito_id = ?',
      whereArgs: [habitoId],
    );
    if (maps.isNotEmpty) return Estadistica.fromMap(maps.first);
    return null;
  }

  // R: Obtener TODAS las Estadísticas (Rol Administrador)
  Future<List<Estadistica>> getAllEstadisticas() async {
    final db = await database;
    final maps = await db.query('estadisticas');
    return maps.map((m) => Estadistica.fromMap(m)).toList();
  }

  // U: Actualizar Estadística
  Future<int> updateEstadistica(Estadistica est) async {
    final db = await database;
    return await db.update(
      'estadisticas',
      est.toMap(),
      where: 'habito_id = ?',
      whereArgs: [est.habitoId],
    );
  }

  // D: Eliminar Estadística por ID de Hábito
  Future<int> deleteEstadisticaByHabito(int habitoId) async {
    final db = await database;
    return await db.delete(
      'estadisticas',
      where: 'habito_id = ?',
      whereArgs: [habitoId],
    );
  }

  // ==========================================
  // SHARED PREFERENCES (Persistencia Local de Sesión y Ajustes)
  // ==========================================

  static const String _keyUsuarioId = 'sesion_usuario_id';
  static const String _keyDarkMode = 'pref_dark_mode';
  static const String _keyTamanoLetra = 'pref_tamano_letra';
  static const String _keyOcultarCompletados = 'pref_ocultar_completados';

  // Guarda la sesión del usuario que ha accedido
  Future<void> saveSesionUsuarioId(int usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUsuarioId, usuarioId);
  }

  // Obtiene el ID del usuario con sesión activa (o null si no hay sesión)
  Future<int?> getSesionUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUsuarioId);
  }

  // Cierra la sesión activa borrando el ID guardado en SharedPreferences
  Future<void> clearSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsuarioId);
  }

  // Guardar y cargar preferencias de la app (Tema oscuro, tamaño de letra, etc.)
  Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> saveTamanoLetra(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTamanoLetra, size);
  }

  Future<double> getTamanoLetra() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyTamanoLetra) ?? 16.0;
  }

  Future<void> saveOcultarCompletados(bool hide) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOcultarCompletados, hide);
  }

  Future<bool> getOcultarCompletados() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOcultarCompletados) ?? false;
  }
}
s
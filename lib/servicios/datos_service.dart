import 'package:flutter/material.dart';
import '../modelos/usuario.dart';
import '../modelos/habito.dart';
import '../modelos/estadistica.dart';
import 'database_helper.dart';

// Servicio de Datos Reactivo: Integra la Base de Datos Local (SQLite) y SharedPreferences
// Extiende de ChangeNotifier para notificar cambios a la interfaz de usuario en tiempo real
class DatosService extends ChangeNotifier {
  static final DatosService _instance = DatosService._internal();

  factory DatosService() {
    return _instance;
  }

  DatosService._internal() {
    _cargarPreferencias();
  }

  final _dbHelper = DatabaseHelper.instance;

  Usuario? _usuarioActual;
  bool _isDarkMode = false;
  double _tamanoLetra = 16.0;
  bool _ocultarCompletados = false;

  Usuario? get usuarioActual => _usuarioActual;
  bool get esAdmin => _usuarioActual?.esAdmin ?? false;

  bool get isDarkMode => _isDarkMode;
  set isDarkMode(bool valor) {
    _isDarkMode = valor;
    _dbHelper.saveDarkMode(valor);
    notifyListeners();
  }

  double get tamanoLetra => _tamanoLetra;
  set tamanoLetra(double valor) {
    _tamanoLetra = valor;
    _dbHelper.saveTamanoLetra(valor);
    notifyListeners();
  }

  bool get ocultarCompletados => _ocultarCompletados;
  set ocultarCompletados(bool valor) {
    _ocultarCompletados = valor;
    _dbHelper.saveOcultarCompletados(valor);
    notifyListeners();
  }

  // Carga preferencias locales guardadas en SharedPreferences
  Future<void> _cargarPreferencias() async {
    _isDarkMode = await _dbHelper.getDarkMode();
    _tamanoLetra = await _dbHelper.getTamanoLetra();
    _ocultarCompletados = await _dbHelper.getOcultarCompletados();

    // Intentar recuperar sesión activa en SharedPreferences
    final sesionUserId = await _dbHelper.getSesionUsuarioId();
    if (sesionUserId != null) {
      _usuarioActual = await _dbHelper.getUsuarioById(sesionUserId);
    }
    notifyListeners();
  }

  // Restablece preferencias y borra sesión activa
  Future<void> restablecerDatos() async {
    _usuarioActual = null;
    _isDarkMode = false;
    _tamanoLetra = 16.0;
    _ocultarCompletados = false;
    await _dbHelper.clearSesion();
    await _dbHelper.saveDarkMode(false);
    await _dbHelper.saveTamanoLetra(16.0);
    await _dbHelper.saveOcultarCompletados(false);
    notifyListeners();
  }

  // LOGIN: Consulta en la tabla 'usuarios' de SQLite y guarda la sesión en SharedPreferences
  Future<Usuario?> login(String usuario, String password) async {
    final user = await _dbHelper.getUsuarioByUsername(usuario);
    if (user != null && user.password == password) {
      _usuarioActual = user;
      if (user.id != null) {
        await _dbHelper.saveSesionUsuarioId(user.id!);
      }
      notifyListeners();
      return user;
    }
    return null;
  }

  // LOGOUT: Borra la sesión de SharedPreferences
  Future<void> logout() async {
    _usuarioActual = null;
    await _dbHelper.clearSesion();
    notifyListeners();
  }

  // REGISTRO DE USUARIO: Inserta en la tabla 'usuarios' de SQLite
  Future<bool> registrarUsuario({
    required String usuario,
    required String nombre,
    required String apellidos,
    required String email,
    required String password,
    String rol = 'usuario',
  }) async {
    final existe = await _dbHelper.getUsuarioByUsername(usuario);
    if (existe != null) return false; // El nombre de usuario ya existe

    final nuevoUsuario = Usuario(
      usuario: usuario.trim(),
      nombre: nombre.trim(),
      apellidos: apellidos.trim(),
      email: email.trim(),
      password: password,
      fechaCreacion: DateTime.now(), // Asignada automáticamente
      rol: rol,
    );

    await _dbHelper.insertUsuario(nuevoUsuario);
    notifyListeners();
    return true;
  }

  // HÁBITOS: CRUD completo en SQLite

  // R: Obtener hábitos de un usuario específico
  Future<List<Habito>> obtenerHabitos(int usuarioId) async {
    final todos = await _dbHelper.getHabitosByUsuario(usuarioId);
    if (_ocultarCompletados) {
      return todos.where((h) => !h.completadoHoy).toList();
    }
    return todos;
  }

  // R: Obtener todos los hábitos (Rol Administrador)
  Future<List<Habito>> obtenerTodosLosHabitos() async {
    return await _dbHelper.getAllHabitos();
  }

  // C: Crear Hábito en la tabla 'habitos'
  Future<void> crearHabito(int usuarioId, String nombre, Color color, IconData icono) async {
    final nuevoHabito = Habito(
      usuarioId: usuarioId,
      nombre: nombre,
      color: color,
      icono: icono,
      completadoHoy: false,
      fechasCompletado: [],
    );

    await _dbHelper.insertHabito(nuevoHabito);
    notifyListeners();
  }

  // U: Modificar Hábito
  Future<void> editarHabito(Habito habito, String nombre, Color color, IconData icono) async {
    final habitoActualizado = habito.copyWith(
      nombre: nombre,
      color: color,
      icono: icono,
    );

    await _dbHelper.updateHabito(habitoActualizado);
    notifyListeners();
  }

  // D: Eliminar Hábito
  Future<void> eliminarHabito(int habitoId) async {
    await _dbHelper.deleteHabito(habitoId);
    notifyListeners();
  }

  // COMPLETAR HÁBITO: Actualiza 'habitos' y recalcula la racha/total en la tabla 'estadisticas'
  Future<void> completarHabito(Habito habito) async {
    if (habito.id == null) return;

    final hoyStr = DateTime.now().toIso8601String().split('T').first;
    final nuevoEstado = !habito.completadoHoy;

    final nuevasFechas = List<String>.from(habito.fechasCompletado);
    if (nuevoEstado) {
      if (!nuevasFechas.contains(hoyStr)) nuevasFechas.add(hoyStr);
    } else {
      nuevasFechas.remove(hoyStr);
    }

    final habitoModificado = habito.copyWith(
      completadoHoy: nuevoEstado,
      fechasCompletado: nuevasFechas,
    );

    await _dbHelper.updateHabito(habitoModificado);

    // Actualizar tabla 'estadisticas'
    final estActual = await _dbHelper.getEstadisticaByHabito(habito.id!);
    int racha = estActual?.rachaActual ?? 0;
    int total = estActual?.totalDiasCompletados ?? 0;

    if (nuevoEstado) {
      racha += 1;
      total += 1;
    } else {
      racha = racha > 0 ? racha - 1 : 0;
      total = total > 0 ? total - 1 : 0;
    }

    final estNueva = Estadistica(
      id: estActual?.id,
      habitoId: habito.id!,
      rachaActual: racha,
      totalDiasCompletados: total,
    );

    await _dbHelper.updateEstadistica(estNueva);
    notifyListeners();
  }

  // ESTADÍSTICAS: Obtener datos de la tabla 'estadisticas'
  Future<Estadistica?> obtenerEstadistica(int habitoId) async {
    return await _dbHelper.getEstadisticaByHabito(habitoId);
  }

  Future<List<Estadistica>> obtenerTodasLasEstadisticas() async {
    return await _dbHelper.getAllEstadisticas();
  }

  // USUARIOS (Rol Administrador): CRUD en SQLite
  Future<List<Usuario>> obtenerUsuarios() async {
    return await _dbHelper.getUsuarios();
  }

  Future<void> eliminarUsuario(int usuarioId) async {
    await _dbHelper.deleteUsuario(usuarioId);
    notifyListeners();
  }
}

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

  DatosService._internal();

  final _dbHelper = DatabaseHelper.instance;

  Usuario? _usuarioActual;
  bool _isDarkMode = false;
  double _tamanoLetra = 16.0;
  bool _ocultarCompletados = false;
  bool _inicializado = false;

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

  // ==========================================
  // INICIO: se llama desde main() antes de arrancar la app
  // Carga los ajustes y la sesión guardados en SharedPreferences
  // ==========================================
  Future<void> init() async {
    if (_inicializado) return;
    _isDarkMode = await _dbHelper.getDarkMode();
    _tamanoLetra = await _dbHelper.getTamanoLetra();
    _ocultarCompletados = await _dbHelper.getOcultarCompletados();

    // Si había una sesión abierta, recupera el usuario desde SQLite
    final sesionUserId = await _dbHelper.getSesionUsuarioId();
    if (sesionUserId != null) {
      _usuarioActual = await _dbHelper.getUsuarioById(sesionUserId);
    }
    _inicializado = true;
    notifyListeners();
  }

  // Borra la base de datos SQLite (se vuelve a crear con los datos de ejemplo)
  // y restablece los ajustes y la sesión de SharedPreferences
  Future<void> restablecerDatos() async {
    _usuarioActual = null;
    _isDarkMode = false;
    _tamanoLetra = 16.0;
    _ocultarCompletados = false;
    await _dbHelper.clearSesion();
    await _dbHelper.saveDarkMode(false);
    await _dbHelper.saveTamanoLetra(16.0);
    await _dbHelper.saveOcultarCompletados(false);
    await _dbHelper.borrarBaseDatos();
    notifyListeners();
  }

  // ==========================================
  // CÁLCULO DE ESTADÍSTICAS A PARTIR DE LAS FECHAS
  // ==========================================

  static String _fecha(DateTime d) => d.toIso8601String().split('T').first;

  // Racha actual: días seguidos completados hasta hoy (o hasta ayer si hoy aún no se ha hecho)
  static int calcularRacha(List<String> fechas) {
    final set = fechas.toSet();
    var dia = DateTime.now();
    if (!set.contains(_fecha(dia))) {
      dia = dia.subtract(const Duration(days: 1));
    }
    int racha = 0;
    while (set.contains(_fecha(dia))) {
      racha++;
      dia = dia.subtract(const Duration(days: 1));
    }
    return racha;
  }

  // ==========================================
  // USUARIOS: login, registro y CRUD (administrador)
  // ==========================================

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

  // C: REGISTRO DE USUARIO en la tabla 'usuarios'
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

  // R: Todos los usuarios (administrador)
  Future<List<Usuario>> obtenerUsuarios() async {
    return await _dbHelper.getUsuarios();
  }

  // U: Actualizar usuario (administrador)
  Future<bool> actualizarUsuario(Usuario usuario) async {
    // Comprueba que el nombre de usuario no lo tenga otra persona
    final otro = await _dbHelper.getUsuarioByUsername(usuario.usuario);
    if (otro != null && otro.id != usuario.id) return false;

    await _dbHelper.updateUsuario(usuario);
    if (_usuarioActual?.id == usuario.id) _usuarioActual = usuario;
    notifyListeners();
    return true;
  }

  // D: Eliminar usuario y sus hábitos (administrador)
  Future<void> eliminarUsuario(int usuarioId) async {
    await _dbHelper.deleteUsuario(usuarioId);
    notifyListeners();
  }

  // ==========================================
  // HÁBITOS: CRUD completo en SQLite
  // ==========================================

  // R: Hábitos de un usuario (el filtro "ocultar completados" se aplica en HabitosPage)
  Future<List<Habito>> obtenerHabitos(int usuarioId) async {
    return await _dbHelper.getHabitosByUsuario(usuarioId);
  }

  // R: Todos los hábitos (administrador)
  Future<List<Habito>> obtenerTodosLosHabitos() async {
    return await _dbHelper.getAllHabitos();
  }

  // C: Crear hábito (también crea su fila en 'estadisticas')
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

  // U: Modificar hábito
  Future<void> editarHabito(Habito habito, String nombre, Color color, IconData icono) async {
    final habitoActualizado = habito.copyWith(
      nombre: nombre,
      color: color,
      icono: icono,
    );

    await _dbHelper.updateHabito(habitoActualizado);
    notifyListeners();
  }

  // D: Eliminar hábito (y su estadística)
  Future<void> eliminarHabito(int habitoId) async {
    await _dbHelper.deleteHabito(habitoId);
    notifyListeners();
  }

  // COMPLETAR HÁBITO: añade o quita la fecha de hoy y recalcula la estadística
  Future<void> completarHabito(Habito habito) async {
    if (habito.id == null) return;

    final hoyStr = _fecha(DateTime.now());
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

    await _guardarEstadistica(habito.id!, nuevasFechas);
    notifyListeners();
  }

  // Calcula racha y total desde las fechas y lo guarda en 'estadisticas'
  Future<void> _guardarEstadistica(int habitoId, List<String> fechas) async {
    final estActual = await _dbHelper.getEstadisticaByHabito(habitoId);
    final estNueva = Estadistica(
      id: estActual?.id,
      habitoId: habitoId,
      rachaActual: calcularRacha(fechas),
      totalDiasCompletados: fechas.toSet().length,
    );

    if (estActual == null) {
      await _dbHelper.insertEstadistica(estNueva);
    } else {
      await _dbHelper.updateEstadistica(estNueva);
    }
  }

  // ==========================================
  // ESTADÍSTICAS: CRUD completo en SQLite
  // ==========================================

  // R: Estadística de un hábito
  Future<Estadistica?> obtenerEstadistica(int habitoId) async {
    return await _dbHelper.getEstadisticaByHabito(habitoId);
  }

  // R: Todas las estadísticas (administrador)
  Future<List<Estadistica>> obtenerTodasLasEstadisticas() async {
    return await _dbHelper.getAllEstadisticas();
  }

  // C: Crear estadística (administrador), calculada desde las fechas del hábito
  Future<void> crearEstadistica(Habito habito) async {
    if (habito.id == null) return;
    await _guardarEstadistica(habito.id!, habito.fechasCompletado);
    notifyListeners();
  }

  // U: Actualizar estadística a mano (administrador)
  Future<void> actualizarEstadistica(Estadistica est) async {
    await _dbHelper.updateEstadistica(est);
    notifyListeners();
  }

  // D: Eliminar estadística (administrador)
  Future<void> eliminarEstadistica(int habitoId) async {
    await _dbHelper.deleteEstadisticaByHabito(habitoId);
    notifyListeners();
  }
}

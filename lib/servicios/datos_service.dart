import 'package:flutter/material.dart';
import '../modelos/usuario.dart';
import '../modelos/habito.dart';

class DatosService {
  static final DatosService _instance = DatosService._internal();

  factory DatosService() {
    return _instance;
  }

  DatosService._internal() {
    _inicializarDatos();
  }

  final List<Usuario> _usuarios = [];
  final List<Habito> _habitos = [];

  void _inicializarDatos() {
    final fechaBase = DateTime.now().subtract(const Duration(days: 15));

    final admin = Usuario(
      id: 'admin_1',
      nombre: 'Administrador',
      usuario: 'admin',
      password: 'admin',
      fechaCreacion: fechaBase,
      esAdmin: true,
    );

    final userDefault = Usuario(
      id: 'user_1',
      nombre: 'Usuario Estándar',
      usuario: 'usuario',
      password: '1234',
      fechaCreacion: fechaBase,
      esAdmin: false,
    );

    _usuarios.addAll([admin, userDefault]);

    _habitos.addAll([
      Habito(
        id: 'h1',
        usuarioId: 'user_1',
        nombre: 'Hacer Ejercicio',
        color: Colors.teal,
        icono: Icons.fitness_center,
        completadoHoy: true,
        racha: 5,
        total: 12,
      ),
      Habito(
        id: 'h2',
        usuarioId: 'user_1',
        nombre: 'Leer 20 Minutos',
        color: Colors.orange,
        icono: Icons.menu_book,
        completadoHoy: false,
        racha: 3,
        total: 8,
      ),
      Habito(
        id: 'h3',
        usuarioId: 'user_1',
        nombre: 'Beber 2L de Agua',
        color: Colors.blue,
        icono: Icons.local_drink,
        completadoHoy: true,
        racha: 10,
        total: 25,
      ),
      Habito(
        id: 'h4',
        usuarioId: 'admin_1',
        nombre: 'Revisar métricas del sistema',
        color: Colors.purple,
        icono: Icons.star,
        completadoHoy: false,
        racha: 2,
        total: 4,
      ),
    ]);
  }

  Usuario? login(String usuario, String password) {
    try {
      return _usuarios.firstWhere(
        (u) =>
            u.usuario.trim().toLowerCase() == usuario.trim().toLowerCase() &&
            u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  bool registrarUsuario(Usuario usuario) {
    final existe = _usuarios.any(
      (u) => u.usuario.trim().toLowerCase() == usuario.usuario.trim().toLowerCase(),
    );
    if (existe) return false;

    _usuarios.add(usuario);
    return true;
  }

  List<Usuario> obtenerUsuarios() => List.unmodifiable(_usuarios);

  void eliminarUsuario(String id) {
    _usuarios.removeWhere((u) => u.id == id);
    _habitos.removeWhere((h) => h.usuarioId == id);
  }

  List<Habito> obtenerHabitos(String usuarioId) {
    return _habitos.where((h) => h.usuarioId == usuarioId).toList();
  }

  List<Habito> obtenerTodosLosHabitos() => List.unmodifiable(_habitos);

  void crearHabito(Usuario usuario, String nombre, Color color, IconData icono) {
    final nuevoHabito = Habito(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      usuarioId: usuario.id,
      nombre: nombre,
      color: color,
      icono: icono,
      completadoHoy: false,
      racha: 0,
      total: 0,
    );
    _habitos.add(nuevoHabito);
  }

  void editarHabito(Habito habito, String nombre, Color color, IconData icono) {
    final index = _habitos.indexWhere((h) => h.id == habito.id);
    if (index >= 0) {
      _habitos[index] = _habitos[index].copyWith(
        nombre: nombre,
        color: color,
        icono: icono,
      );
    }
  }

  void eliminarHabito(String id) {
    _habitos.removeWhere((h) => h.id == id);
  }

  void completarHabito(Habito habito) {
    final index = _habitos.indexWhere((h) => h.id == habito.id);
    if (index >= 0) {
      final h = _habitos[index];
      final nuevoEstado = !h.completadoHoy;
      final nuevaRacha = nuevoEstado
          ? h.racha + 1
          : (h.racha > 0 ? h.racha - 1 : 0);
      final nuevosTotales = nuevoEstado
          ? h.total + 1
          : (h.total > 0 ? h.total - 1 : 0);

      _habitos[index] = h.copyWith(
        completadoHoy: nuevoEstado,
        racha: nuevaRacha,
        total: nuevosTotales,
      );
    }
  }
}

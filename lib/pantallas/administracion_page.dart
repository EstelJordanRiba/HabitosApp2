import 'package:flutter/material.dart';
import '../modelos/usuario.dart';
import '../modelos/habito.dart';
import '../modelos/estadistica.dart';
import '../servicios/datos_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import '../widgets/tarjeta_habito.dart';
import '../widgets/dato_estadistica.dart';
import 'editar_habito_page.dart';

// Pantalla 6: Administración (AdministracionPage) - Rol Administrador
// Ofrece control CRUD completo sobre las 3 tablas de la base de datos SQLite: 'usuarios', 'habitos' y 'estadisticas'
class AdministracionPage extends StatefulWidget {
  const AdministracionPage({super.key});

  @override
  State<AdministracionPage> createState() => _AdministracionPageState();
}

class _AdministracionPageState extends State<AdministracionPage> {
  final _datos = DatosService();
  List<Usuario> _usuarios = [];
  List<Habito> _todosLosHabitos = [];
  Map<int, Estadistica> _mapEstadisticas = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosGlobales();
  }

  // Consulta asíncrona de todas las tablas en SQLite
  Future<void> _cargarDatosGlobales() async {
    setState(() => _cargando = true);
    final users = await _datos.obtenerUsuarios();
    final habitos = await _datos.obtenerTodosLosHabitos();
    final statsList = await _datos.obtenerTodasLasEstadisticas();

    Map<int, Estadistica> mapE = {};
    for (var s in statsList) {
      mapE[s.habitoId] = s;
    }

    if (mounted) {
      setState(() {
        _usuarios = users;
        _todosLosHabitos = habitos;
        _mapEstadisticas = mapE;
        _cargando = false;
      });
    }
  }

  // C: Crear Usuario desde Administración
  void _dialogoCrearUsuario() {
    final usuarioCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();
    final apellidosCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String rolSeleccionado = 'usuario';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Crear Usuario (Administrador)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CampoTextoApp(etiqueta: 'Usuario', controller: usuarioCtrl),
                CampoTextoApp(etiqueta: 'Nombre', controller: nombreCtrl),
                CampoTextoApp(etiqueta: 'Apellidos', controller: apellidosCtrl),
                CampoTextoApp(etiqueta: 'Email', controller: emailCtrl),
                CampoTextoApp(
                  etiqueta: 'Contraseña',
                  controller: passCtrl,
                  ocultarTexto: true,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Rol: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: rolSeleccionado,
                      items: const [
                        DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                        DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => rolSeleccionado = val);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            SizedBox(
              width: 130,
              child: BotonPrincipal(
                texto: 'Crear',
                onPressed: () async {
                  if (usuarioCtrl.text.isNotEmpty &&
                      nombreCtrl.text.isNotEmpty &&
                      emailCtrl.text.isNotEmpty &&
                      passCtrl.text.isNotEmpty) {
                    await _datos.registrarUsuario(
                      usuario: usuarioCtrl.text.trim(),
                      nombre: nombreCtrl.text.trim(),
                      apellidos: apellidosCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      password: passCtrl.text,
                      rol: rolSeleccionado,
                    );
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    await _cargarDatosGlobales();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // D: Eliminar Usuario y sus registros asociados en la BD
  Future<void> _confirmarEliminarUsuario(Usuario u) async {
    final aceptado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Seguro que quieres eliminar a "${u.nombre}" de la base de datos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (aceptado == true && u.id != null) {
      await _datos.eliminarUsuario(u.id!);
      await _cargarDatosGlobales();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel de Administración (SQLite)'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Usuarios'),
              Tab(icon: Icon(Icons.list_alt), text: 'Hábitos'),
              Tab(icon: Icon(Icons.analytics), text: 'Estadísticas'),
            ],
          ),
        ),
        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Tab 1: Tabla 'usuarios' (CRUD completo)
                  ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tabla Usuarios',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: _dialogoCrearUsuario,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Nuevo usuario'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._usuarios.map((u) => Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: u.esAdmin ? Colors.purple : Colors.teal,
                                child: Icon(
                                  u.esAdmin ? Icons.shield : Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text('${u.nombre} ${u.apellidos} (@${u.usuario})'),
                              subtitle: Text(
                                'Email: ${u.email}\nRol: ${u.rol} | Creado: ${u.fechaCreacion.toIso8601String().split('T').first}',
                              ),
                              trailing: u.esAdmin
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _confirmarEliminarUsuario(u),
                                    ),
                            ),
                          )),
                    ],
                  ),

                  // Tab 2: Tabla 'habitos' (CRUD completo)
                  ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _todosLosHabitos.length,
                    itemBuilder: (context, i) {
                      final h = _todosLosHabitos[i];
                      final propietario = _usuarios.firstWhere(
                        (u) => u.id == h.usuarioId,
                        orElse: () => Usuario(
                          usuario: 'desconocido',
                          nombre: 'Desconocido',
                          apellidos: '',
                          email: '',
                          password: '',
                          fechaCreacion: DateTime.now(),
                        ),
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, top: 4),
                            child: Text(
                              'Propietario: ${propietario.nombre} ${propietario.apellidos}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TarjetaHabito(
                            nombre: h.nombre,
                            color: h.color,
                            icono: h.icono,
                            completadoHoy: h.completadoHoy,
                            onCompletar: () async {
                              await _datos.completarHabito(h);
                              await _cargarDatosGlobales();
                            },
                            onEditar: () async {
                              final guardado = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditarHabitoPage(
                                    usuario: propietario,
                                    habito: h,
                                  ),
                                ),
                              );
                              if (guardado == true) await _cargarDatosGlobales();
                            },
                            onEliminar: () async {
                              final aceptado = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Eliminar hábito'),
                                  content: Text(
                                      '¿Seguro que quieres eliminar "${h.nombre}" de SQLite?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                              if (aceptado == true && h.id != null) {
                                await _datos.eliminarHabito(h.id!);
                                await _cargarDatosGlobales();
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  // Tab 3: Tabla 'estadisticas' (Consulta y resumen por usuario)
                  ListView(
                    padding: const EdgeInsets.all(12),
                    children: _usuarios.map((u) {
                      final habitosUser = _todosLosHabitos.where((h) => h.usuarioId == u.id).toList();
                      if (habitosUser.isEmpty) return const SizedBox.shrink();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Usuario: ${u.nombre} ${u.apellidos}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              const Divider(),
                              ...habitosUser.map((h) {
                                final est = _mapEstadisticas[h.id] ??
                                    Estadistica(
                                      habitoId: h.id ?? 0,
                                      rachaActual: 0,
                                      totalDiasCompletados: 0,
                                    );
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        h.nombre,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          DatoEstadistica(
                                            etiqueta: 'Racha',
                                            valor: '${est.rachaActual} d',
                                            icono: Icons.local_fire_department,
                                            color: h.color,
                                          ),
                                          DatoEstadistica(
                                            etiqueta: 'Total completados',
                                            valor: '${est.totalDiasCompletados}',
                                            icono: Icons.check_circle,
                                            color: h.color,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
      ),
    );
  }
}

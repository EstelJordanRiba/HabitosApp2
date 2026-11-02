import 'package:flutter/material.dart';
import '../modelos/usuario.dart';
import '../modelos/habito.dart';
import '../servicios/datos_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';
import '../widgets/tarjeta_habito.dart';
import '../widgets/dato_estadistica.dart';
import 'editar_habito_page.dart';

class AdministracionPage extends StatefulWidget {
  const AdministracionPage({super.key});

  @override
  State<AdministracionPage> createState() => _AdministracionPageState();
}

class _AdministracionPageState extends State<AdministracionPage> {
  final _datos = DatosService();

  void _recargar() {
    setState(() {});
  }

  void _dialogoCrearUsuario() {
    final nombreCtrl = TextEditingController();
    final usuarioCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Usuario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CampoTextoApp(etiqueta: 'Nombre completo', controller: nombreCtrl),
              CampoTextoApp(etiqueta: 'Usuario', controller: usuarioCtrl),
              CampoTextoApp(
                etiqueta: 'Contraseña',
                controller: passCtrl,
                ocultarTexto: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          SizedBox(
            width: 130,
            child: BotonPrincipal(
              texto: 'Crear',
              onPressed: () {
                if (nombreCtrl.text.isNotEmpty &&
                    usuarioCtrl.text.isNotEmpty &&
                    passCtrl.text.isNotEmpty) {
                  _datos.registrarUsuario(
                    Usuario(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      nombre: nombreCtrl.text.trim(),
                      usuario: usuarioCtrl.text.trim(),
                      password: passCtrl.text,
                      fechaCreacion: DateTime.now(),
                      esAdmin: false,
                    ),
                  );
                  Navigator.pop(context);
                  _recargar();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminarUsuario(Usuario u) async {
    final aceptado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Seguro que quieres eliminar a "${u.nombre}"?'),
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

    if (aceptado == true) {
      _datos.eliminarUsuario(u.id);
      _recargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarios = _datos.obtenerUsuarios();
    final todosLosHabitos = _datos.obtenerTodosLosHabitos();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administración'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'Usuarios'),
              Tab(icon: Icon(Icons.list_alt), text: 'Hábitos'),
              Tab(icon: Icon(Icons.analytics), text: 'Estadísticas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Usuarios
            ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gestión de usuarios',
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
                ...usuarios.map((u) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: u.esAdmin ? Colors.purple : Colors.teal,
                          child: Icon(
                            u.esAdmin ? Icons.shield : Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(u.nombre),
                        subtitle: Text(
                          'Usuario: ${u.usuario} | ${u.esAdmin ? "Admin" : "Estándar"}',
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

            // Tab 2: Hábitos globales
            ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: todosLosHabitos.length,
              itemBuilder: (context, i) {
                final h = todosLosHabitos[i];
                final propietario = usuarios.firstWhere(
                  (u) => u.id == h.usuarioId,
                  orElse: () => Usuario(
                    id: '',
                    nombre: 'Desconocido',
                    usuario: '',
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
                        'Propietario: ${propietario.nombre}',
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
                      onCompletar: () {
                        _datos.completarHabito(h);
                        _recargar();
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
                        if (guardado == true) _recargar();
                      },
                      onEliminar: () async {
                        final aceptado = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Eliminar hábito'),
                            content: Text(
                                '¿Seguro que quieres eliminar "${h.nombre}"?'),
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
                        if (aceptado == true) {
                          _datos.eliminarHabito(h.id);
                          _recargar();
                        }
                      },
                    ),
                  ],
                );
              },
            ),

            // Tab 3: Estadísticas globales agrupadas por usuario
            ListView(
              padding: const EdgeInsets.all(12),
              children: usuarios.map((u) {
                final habitosUsuario = _datos.obtenerHabitos(u.id);
                if (habitosUsuario.isEmpty) return const SizedBox.shrink();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usuario: ${u.nombre}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const Divider(),
                        ...habitosUsuario.map((h) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    h.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      DatoEstadistica(
                                        etiqueta: 'Racha',
                                        valor: '${h.racha} d',
                                        icono: Icons.local_fire_department,
                                        color: h.color,
                                      ),
                                      DatoEstadistica(
                                        etiqueta: 'Total',
                                        valor: '${h.total}',
                                        icono: Icons.check_circle,
                                        color: h.color,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
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

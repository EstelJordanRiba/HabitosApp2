import 'package:flutter/material.dart';
import '../modelos/usuario.dart';
import '../modelos/habito.dart';
import '../servicios/datos_service.dart';
import '../widgets/campo_texto_app.dart';
import '../widgets/boton_principal.dart';

// Pantalla 4: Crear / Editar Hábitos (EditarHabitoPage)
// Permite guardar o actualizar un hábito en la base de datos local SQLite
class EditarHabitoPage extends StatefulWidget {
  final Usuario usuario;
  final Habito? habito;

  const EditarHabitoPage({
    super.key,
    required this.usuario,
    this.habito,
  });

  @override
  State<EditarHabitoPage> createState() => _EditarHabitoPageState();
}

class _EditarHabitoPageState extends State<EditarHabitoPage> {
  final _datos = DatosService();
  late TextEditingController _nombreCtrl;
  late Color _color;
  late IconData _icono;

  static const _colores = [
    Colors.teal,
    Colors.orange,
    Colors.purple,
    Colors.blue,
    Colors.red,
    Colors.green,
  ];

  static const _iconos = [
    Icons.star,
    Icons.fitness_center,
    Icons.local_drink,
    Icons.menu_book,
    Icons.bedtime,
    Icons.self_improvement,
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.habito;
    _nombreCtrl = TextEditingController(text: h?.nombre ?? '');
    _color = h?.color ?? _colores.first;
    _icono = h?.icono ?? _iconos.first;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  Widget _selectorColor() => Wrap(
        spacing: 12,
        children: _colores
            .map(
              (c) => GestureDetector(
                onTap: () => setState(() => _color = c),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: c,
                  child: _color == c
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              ),
            )
            .toList(),
      );

  Widget _selectorIcono() => Wrap(
        spacing: 8,
        children: _iconos
            .map(
              (i) => IconButton(
                icon: Icon(i),
                color: _icono == i ? _color : Colors.grey,
                onPressed: () => setState(() => _icono = i),
              ),
            )
            .toList(),
      );

  Future<void> _guardar() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      _mensaje('El nombre es obligatorio');
      return;
    }
    final nombre = _nombreCtrl.text.trim();
    if (widget.usuario.id == null) return;

    if (widget.habito == null) {
      // Inserción en la base de datos SQLite (tabla habitos + estadisticas)
      await _datos.crearHabito(widget.usuario.id!, nombre, _color, _icono);
    } else {
      // Actualización en la base de datos SQLite
      await _datos.editarHabito(widget.habito!, nombre, _color, _icono);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.habito != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar hábito' : 'Nuevo hábito'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CampoTextoApp(
              etiqueta: 'Nombre del hábito',
              controller: _nombreCtrl,
            ),
            const SizedBox(height: 16),
            const Text(
              'Color identificativo:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _selectorColor(),
            const SizedBox(height: 16),
            const Text(
              'Icono:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _selectorIcono(),
            const SizedBox(height: 24),
            BotonPrincipal(texto: 'Guardar', onPressed: _guardar),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

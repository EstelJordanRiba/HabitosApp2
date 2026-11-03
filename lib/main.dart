import 'package:flutter/material.dart';
import 'pantallas/login_page.dart';
import 'servicios/datos_service.dart';

// Punto de entrada principal de la aplicación Flutter
void main() {
  // Garantiza que la infraestructura de Flutter esté totalmente lista antes de arrancar
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HabitosApp());
}

// Widget raíz de la aplicación (StatelessWidget porque la configuración global la gestiona MaterialApp)
class HabitosApp extends StatelessWidget {
  const HabitosApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos la instancia del servicio de datos
    final datos = DatosService();

    // ListenableBuilder escucha cambios en DatosService (por ejemplo, si el usuario cambia el tema o el tamaño de letra)
    // y redibuja automáticamente la aplicación para aplicar las preferencias del usuario.
    return ListenableBuilder(
      listenable: datos,
      builder: (context, _) {
        return MaterialApp(
          title: 'HábitosApp',
          debugShowCheckedModeBanner: false, // Oculta la marca de agua 'DEBUG' en la esquina
          // Tema claro con color semilla Teal (verde azulado)
          theme: ThemeData(
            colorSchemeSeed: Colors.teal,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          // Tema oscuro con color semilla Teal
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.teal,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          // Alterna entre modo claro u oscuro según lo seleccionado en DatosService
          themeMode: datos.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // Ajusta dinámicamente la escala global del texto en toda la app según las opciones de accesibilidad
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(datos.tamanoLetra / 16.0),
              ),
              child: child!,
            );
          },
          // Definimos LoginPage como la pantalla inicial de la aplicación
          home: const LoginPage(),
        );
      },
    );
  }
}

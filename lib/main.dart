import 'package:flutter/material.dart';
import 'pantallas/login_page.dart';
import 'pantallas/habitos_page.dart';
import 'servicios/datos_service.dart';

// main.dart
// FUNCIÓN: Punto de entrada raíz de la aplicación HábitosApp
// Este archivo inicializa el motor de Flutter, restaura la sesión persistida
// en SharedPreferences y la base de datos SQLite antes de renderizar la app,
// y configura el tema visual reactivo (modo claro/oscuro y tamaño de letra).


Future<void> main() async {
  // Garantiza que los bindings del framework de Flutter estén totalmente listos
  // antes de realizar llamadas asíncronas a SQLite o SharedPreferences.
  WidgetsFlutterBinding.ensureInitialized();

  // Carga preferencias de usuario y comprueba si existe una sesión activa guardada
  await DatosService().init();

  // Inicia la ejecución de la app Flutter
  runApp(const HabitosApp());
}

// Widget raíz de tipo StatelessWidget.
// La reactividad del tema visual se gestiona escuchando a DatosService mediante ListenableBuilder.
class HabitosApp extends StatelessWidget {
  const HabitosApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos la instancia única (Singleton) del servicio de datos
    final datos = DatosService();

    // Determinamos la pantalla de inicio al arrancar:
    // Si SharedPreferences recordaba al usuario en sesión, entra directo a HabitosPage.
    // De lo contrario, solicita autenticación mostrando LoginPage.
    final Widget pantallaInicial = datos.usuarioActual != null
        ? HabitosPage(usuario: datos.usuarioActual!)
        : const LoginPage();

    // ListenableBuilder: Se activa cada vez que DatosService llama a notifyListeners()
    // (por ejemplo, cuando el usuario altera el tema claro/oscuro o la escala de letra en Ajustes).
    return ListenableBuilder(
      listenable: datos,
      builder: (context, _) {
        return MaterialApp(
          title: 'HábitosApp',
          debugShowCheckedModeBanner: false, // Oculta el cartelito 'DEBUG' en la esquina de la pantalla

          // Tema claro con color semilla Teal
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

          // Selección del tema según el booleano guardado en SharedPreferences
          themeMode: datos.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // Escalado de fuente dinámico para toda la interfaz gráfica de la app
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(datos.tamanoLetra / 16.0),
              ),
              child: child!,
            );
          },

          // Carga la pantalla inicial calculada según la sesión activa
          home: pantallaInicial,
        );
      },
    );
  }
}

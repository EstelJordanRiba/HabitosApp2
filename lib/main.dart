import 'package:flutter/material.dart';
import 'pantallas/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HabitosApp());
}

class HabitosApp extends StatelessWidget {
  const HabitosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HábitosApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

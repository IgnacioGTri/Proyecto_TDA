import 'package:flutter/material.dart';
import 'Menus/main_menu_screen.dart';
void main() => runApp(const MiMenuApp());

class MiMenuApp extends StatelessWidget {
  const MiMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prototipo Menú',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const MainMenuScreen(),
    );
  }
}
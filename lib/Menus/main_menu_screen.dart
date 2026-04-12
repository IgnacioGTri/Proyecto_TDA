import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../BotonesExtrax/Favoritos.dart';
import '../BotonesExtrax/RecordsMenuScreen.dart';
import 'games_menu_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo con un sutil gradiente para que no sea solo blanco
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade50, Colors.grey.shade200],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título o Logo de la App
                const Text(
                  "T.D.A",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 60),

                // Botones principales
                _menuButton(
                  context,
                  'JUGAR',
                  Icons.play_arrow_rounded,
                  Colors.blue.shade700,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GamesMenuScreen())),
                ),
                const SizedBox(height: 20),

                _menuButton(
                  context,
                  'FAVORITOS',
                  Icons.favorite_rounded,
                  Colors.red.shade400,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Favoritos())),
                ),
                const SizedBox(height: 20),

                _menuButton(
                  context,
                  'RECORDS',
                  Icons.emoji_events_rounded,
                  Colors.amber.shade700,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecordsMenuScreen())),
                ),
                const SizedBox(height: 40),

                // Botón de salir más discreto
                TextButton.icon(
                  onPressed: () => SystemNavigator.pop(),
                  icon: const Icon(Icons.exit_to_app, color: Colors.grey),
                  label: const Text('SALIR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Nuevo diseño de botón: Más moderno, con icono y elevación
  Widget _menuButton(BuildContext context, String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0, // La sombra la da el Container para más control
        ),
        onPressed: onPressed,
      ),
    );
  }
}
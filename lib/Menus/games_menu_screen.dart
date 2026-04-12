import 'package:flutter/material.dart';
import '../Game/Juego1.dart'; // TapGameWidget
import '../Game/Juego2.dart'; // DragGameWidget
import '../Game/Juego3.dart'; // StarTapGame
import '../Game/Juego4.dart'; // LongPressGame
import '../Game/Juego5.dart'; // DoubleTapGame
import '../Game/Juego6.dart'; // DragShapesGame
import '../Game/Juego7.dart'; // SimonDiceGame (AÑADIDO)

class GamesMenuScreen extends StatelessWidget {
  const GamesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('SELECCIONA UN JUEGO',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _gameCard(context, 'TAP TAP', Icons.touch_app, Colors.orange, const TapGameWidget()),
            _gameCard(context, 'ARRASTRA', Icons.ads_click, Colors.blue, const DragGameWidget()),
            _gameCard(context, 'ESTRELLAS', Icons.auto_awesome, Colors.amber, const StarTapGame()),
            _gameCard(context, 'MANTÉN', Icons.timer_outlined, Colors.green, const LongPressGame()),
            _gameCard(context, 'DOBLE TAP', Icons.repeat_one, Colors.purple, const DoubleTapGame()),
            _gameCard(context, 'FORMAS', Icons.category_rounded, Colors.red, const DragShapesGame()),
            _gameCard(context, 'SIMON DICE', Icons.memory, Colors.pinkAccent, const SimonDiceGame()),
          ],
        ),
      ),
    );
  }

  // Widget para crear tarjetas de juego estéticas
  Widget _gameCard(BuildContext context, String nombre, IconData icono, Color color, Widget destino) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destino)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              nombre,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
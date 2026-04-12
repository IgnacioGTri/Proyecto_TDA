import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para el botón de salir



class MiMenuApp extends StatelessWidget {
  const MiMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prototipo Menú',
      theme: ThemeData(
        // Tema minimalista basándonos en tu dibujo
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

// ---------------------------------------------------
// 1. PANTALLA PRINCIPAL
// ---------------------------------------------------
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _menuButton(
                context,
                'JUGAR',
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GamesScreen())),
              ),
              const SizedBox(height: 20),
              _menuButton(
                context,
                'FAF',
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FavScreen())),
              ),
              const SizedBox(height: 20),
              _menuButton(
                context,
                'SALIR',
                    () {
                  // Cierra la app en Android (En iOS Apple no recomienda botones de salir)
                  SystemNavigator.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Diseño de los botones rectangulares de tu dibujo
  Widget _menuButton(BuildContext context, String text, VoidCallback onPressed) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        side: const BorderSide(color: Colors.black, width: 2), // Borde negro grueso
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Botones cuadrados
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }
}

// ---------------------------------------------------
// 2. PANTALLA DE JUEGOS
// ---------------------------------------------------
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juegos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Botón salir jugar
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 3, // 3 columnas como en tu dibujo
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: List.generate(6, (index) => const GameIconWidget()), // 6 círculos
        ),
      ),
    );
  }
}

// ---------------------------------------------------
// 3. PANTALLA DE FAVORITOS (tuFA)
// ---------------------------------------------------
class FavScreen extends StatelessWidget {
  const FavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volver'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "tuFA'",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            // Círculo relleno de negro (Favorito)
            GameIconWidget(isFavorite: true),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------
// 4. PANTALLA DEL JUEGO (Al hacer clic en un círculo)
// ---------------------------------------------------
class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla de Juego'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Botón para salir del juego
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2), // El recuadro del juego
          ),
          child: const Center(
            child: Text('¡Jugando!', style: TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------
// WIDGET REUTILIZABLE: El círculo del juego
// ---------------------------------------------------
class GameIconWidget extends StatelessWidget {
  final bool isFavorite;

  const GameIconWidget({super.key, this.isFavorite = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // La flecha "Juega" que conecta el círculo con la pantalla del juego
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayScreen())),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFavorite ? Colors.black : Colors.transparent, // Negro si es fav, transparente si no
          border: Border.all(color: Colors.black, width: 2), // Borde como tu dibujo
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Game/Juego1.dart';
import '../Game/Juego2.dart';
import '../Game/Juego3.dart';
import '../Game/Juego4.dart';
import '../Game/Juego5.dart';
import '../Game/Juego6.dart';
import '../Game/Juego7.dart';
import '../Game/Juego8.dart';
import '../BotonesExtrax/Favoritos.dart';

class GamesMenuScreen extends StatefulWidget {
  const GamesMenuScreen({super.key});

  @override
  State<GamesMenuScreen> createState() => _GamesMenuScreenState();
}

class _GamesMenuScreenState extends State<GamesMenuScreen> {
  List<String> _favoritosGuardados = [];

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }
  Future<void> _cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritosGuardados = prefs.getStringList('juegos_favoritos') ?? [];
    });
  }
  Future<void> _intercambiarFavorito(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoritosGuardados.contains(nombre)) {
        _favoritosGuardados.remove(nombre);
      } else {
        _favoritosGuardados.add(nombre);
      }
    });
    await prefs.setStringList('juegos_favoritos', _favoritosGuardados);
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red, size: 28),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Favoritos()),
              );
              _cargarFavoritos();
            },
          )
        ],
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
            _gameCard(context, '3 PUERTAS', Icons.meeting_room, Colors.teal, const Juego8()),
          ],
        ),
      ),
    );
  }

  Widget _gameCard(BuildContext context, String nombre, IconData icono, Color color, Widget destino) {
    bool esFavorito = _favoritosGuardados.contains(nombre);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destino)),
          child: Container(
            width: double.infinity,
            height: double.infinity,
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
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _intercambiarFavorito(nombre),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                  ],
                ),
                child: Icon(
                  esFavorito ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
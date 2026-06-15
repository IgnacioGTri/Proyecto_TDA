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
  void _mostrarInfoJuego(BuildContext context, String nombre, String descripcion, Color color) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.info_outline, color: color, size: 28),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                    )
                ),
              ],
            ),
            content: Text(
                descripcion,
                style: const TextStyle(fontSize: 16, height: 1.4)
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ENTENDIDO', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
    );
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
            _gameCard(context, 'TAP TAP', Icons.touch_app, Colors.orange, const TapGameWidget(),
                "Pon a prueba tu velocidad pulsando la pantalla tantas veces como puedas antes de que se acabe el tiempo."),

            _gameCard(context, 'ARRASTRA', Icons.ads_click, Colors.blue, const DragGameWidget(),
                "Mejora tu coordinación deslizando rápidamente cada elemento hacia su objetivo central."),

            _gameCard(context, 'ESTRELLAS', Icons.auto_awesome, Colors.amber, const StarTapGame(),
                "Entrena tu atención cazando las estrellas correctas antes de que desaparezcan."),

            _gameCard(context, 'MANTÉN', Icons.timer_outlined, Colors.green, const LongPressGame(),
                "Trabaja tu percepción del tiempo. Mantén pulsado el botón y suéltalo justo entre los 2 y 3 segundos exactos."),

            _gameCard(context, 'DOBLE TAP', Icons.repeat_one, Colors.purple, const DoubleTapGame(),
                "Estimula tus reflejos rápidos tocando exactamente dos veces los círculos que se iluminen."),

            _gameCard(context, 'FORMAS', Icons.category_rounded, Colors.red, const DragShapesGame(),
                "Arrastra cada figura geométrica a su silueta correcta antes de que se acabe el límite de tiempo."),

            _gameCard(context, 'SIMON DICE', Icons.memory, Colors.pinkAccent, const SimonDiceGame(),
                "Clásico reto de memoria. Observa la secuencia de colores que da el sistema y repítela sin equivocarte."),

            _gameCard(context, '3 PUERTAS', Icons.meeting_room, Colors.teal, const Juego8(),
                "Basado en el dilema de Monty Hall. Encuentra el premio y descubre cómo cambian tus probabilidades de ganar si decides cambiar de puerta."),
          ],
        ),
      ),
    );
  }
  Widget _gameCard(BuildContext context, String nombre, IconData icono, Color color, Widget destino, String descripcion) {
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
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _mostrarInfoJuego(context, nombre, descripcion, color),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                  ],
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.blueGrey,
                ),
              ),
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
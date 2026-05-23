import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Game/Juego1.dart';
import '../Game/Juego2.dart';
import '../Game/Juego3.dart';
import '../Game/Juego4.dart';
import '../Game/Juego5.dart';
import '../Game/Juego6.dart';
import '../Game/Juego7.dart';

class JuegoFavorito {
  final String nombre;
  final IconData icono;
  final Color color;
  JuegoFavorito({required this.nombre, required this.icono, required this.color});
}
class Favoritos extends StatefulWidget {
  const Favoritos({super.key});
  @override
  State<Favoritos> createState() => _FavoritosState();
}
class _FavoritosState extends State<Favoritos> {
  List<String> _nombresFavoritos = [];
  bool _cargando = true;
  final Map<String, Map<String, dynamic>> _datosJuegos = {
    'TAP TAP': {'icono': Icons.touch_app, 'color': Colors.orange, 'widget': const TapGameWidget()},
    'ARRASTRA': {'icono': Icons.ads_click, 'color': Colors.blue, 'widget': const DragGameWidget()},
    'ESTRELLAS': {'icono': Icons.auto_awesome, 'color': Colors.amber, 'widget': const StarTapGame()},
    'MANTÉN': {'icono': Icons.timer_outlined, 'color': Colors.green, 'widget': const LongPressGame()},
    'DOBLE TAP': {'icono': Icons.repeat_one, 'color': Colors.purple, 'widget': const DoubleTapGame()},
    'FORMAS': {'icono': Icons.category_rounded, 'color': Colors.red, 'widget': const DragShapesGame()},
    'SIMON DICE': {'icono': Icons.memory, 'color': Colors.pinkAccent, 'widget': const SimonDiceGame()},
  };

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombresFavoritos = prefs.getStringList('juegos_favoritos') ?? [];
      _cargando = false;
    });
  }

  Future<void> _eliminarFavorito(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombresFavoritos.remove(nombre);
    });
    await prefs.setStringList('juegos_favoritos', _nombresFavoritos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("MIS JUEGOS FAVORITOS", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _nombresFavoritos.isEmpty
          ? const Center(
        child: Text(
          "Aún no has añadido ningún juego a favoritos",
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _nombresFavoritos.length,
        itemBuilder: (context, index) {
          final nombreJuego = _nombresFavoritos[index];
          final infoJuego = _datosJuegos[nombreJuego] ?? {
            'icono': Icons.gamepad,
            'color': Colors.grey,
            'widget': null
          };

          final IconData icono = infoJuego['icono'];
          final Color color = infoJuego['color'];
          final Widget? juegoWidget = infoJuego['widget'];

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (juegoWidget != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => juegoWidget),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo abrir este juego')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icono, color: color, size: 30),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        nombreJuego,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red, size: 28),
                      onPressed: () => _eliminarFavorito(nombreJuego),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
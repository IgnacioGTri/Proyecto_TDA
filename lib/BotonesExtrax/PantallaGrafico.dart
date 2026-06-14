import 'package:flutter/material.dart';
import '../BaseDeDatos/DatabaseHelper.dart';

class PantallaGrafico extends StatelessWidget {
  final String nombreJuego;
  final String nombrePantalla;

  const PantallaGrafico({
    super.key,
    required this.nombreJuego,
    required this.nombrePantalla
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('EVOLUCIÓN: $nombrePantalla'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper().obtenerHistorialJuego(nombreJuego),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Juega partidas para registrar tu evolución de récords"));
          }

          final historial = snapshot.data!;
          int maxPuntuacion = historial.map((e) => e['puntuacion'] as int).reduce((a, b) => a > b ? a : b);
          if (maxPuntuacion == 0) maxPuntuacion = 1;

          return Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Historial cronológico de puntuaciones (antiguas a recientes):",
                  style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: historial.map((partida) {
                          int pts = partida['puntuacion'] as int;
                          double alturaBarra = (pts / maxPuntuacion) * 250;
                          if (alturaBarra < 20) alturaBarra = 20;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "$pts",
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                ),
                                const SizedBox(height: 8),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  width: 35,
                                  height: alturaBarra,
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.7),
                                    border: Border.all(color: Colors.black, width: 2),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Icon(Icons.videogame_asset_outlined, size: 16, color: Colors.grey),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Total de partidas evaluadas: ${historial.length}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
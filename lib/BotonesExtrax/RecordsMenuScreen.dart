import 'package:flutter/material.dart';
import '../BaseDeDatos/DatabaseHelper.dart';
import 'PantallaGrafico.dart';

class RecordsMenuScreen extends StatelessWidget {
  const RecordsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MEJORES PUNTUACIONES'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<int>(
            future: DatabaseHelper().obtenerTiempoTotal(),
            builder: (context, snapshot) {
              int totalSeg = snapshot.data ?? 0;
              Duration d = Duration(seconds: totalSeg);
              String tiempoTotal = d.inHours > 0
                  ? "${d.inHours}h ${d.inMinutes.remainder(60)}m ${d.inSeconds.remainder(60)}s"
                  : "${d.inMinutes}m ${d.inSeconds.remainder(60)}s";
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  border: Border.all(color: Colors.blueAccent, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      "TIEMPO TOTAL JUGADO",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tiempoTotal,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.blueAccent
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper().getRecords(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("Aún no hay récords guardados")
                    );
                  }
                  final records = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final item = records[index];
                      String idJuego = item['nombreJuego'] ?? "Juego";
                      String nombrePantalla = idJuego.toUpperCase();
                      String sufijoPuntuacion = "Taps";

                      if (idJuego == 'juego8') {
                        nombrePantalla = "3 PUERTAS";
                        sufijoPuntuacion = "Victorias";
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantallaGrafico(
                                nombreJuego: idJuego,
                                nombrePantalla: nombrePantalla,
                              ),
                            ),
                          );
                        },
                        child: _recordTile(
                            nombrePantalla,
                            "${item['puntuacion']} $sufijoPuntuacion",
                            "${item['segundosJugados']}s"
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordTile(String juego, String puntuacion, String tiempo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  juego.toUpperCase(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          Text(
              puntuacion,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold
              )
          ),
        ],
      ),
    );
  }
}
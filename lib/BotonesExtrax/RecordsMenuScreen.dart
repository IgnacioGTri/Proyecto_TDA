import 'package:flutter/material.dart';
import '../BaseDeDatos/DatabaseHelper.dart';
import 'PantallaGrafico.dart';
class RecordsMenuScreen extends StatelessWidget {
  const RecordsMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('PROGRESO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.black,
            indicatorWeight: 4,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(icon: Icon(Icons.leaderboard), text: "RÉCORDS"),
              Tab(icon: Icon(Icons.military_tech), text: "LOGROS"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PestanaRecords(),
            _PestanaLogros(),
          ],
        ),
      ),
    );
  }
}
class _PestanaRecords extends StatelessWidget {
  const _PestanaRecords();

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  const Text("TIEMPO TOTAL JUGADO", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(tiempoTotal, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
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
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Aún no hay récords guardados"));

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
                          MaterialPageRoute(builder: (context) => PantallaGrafico(nombreJuego: idJuego, nombrePantalla: nombrePantalla)),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(nombrePantalla, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("${item['puntuacion']} $sufijoPuntuacion", style: const TextStyle(fontSize: 20, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
class _PestanaLogros extends StatelessWidget {
  const _PestanaLogros();

  List<int> _obtenerMetas(String idJuego) {
    String id = idJuego.toLowerCase();

    if (id.contains('juego8') || id.contains('puerta')) return [5, 10, 20];

    if (id.contains('simon')) return [10, 20, 30];

    if (id.contains('forma') || id.contains('shape')) return [10, 15, 20];

    if (id.contains('arrastra') || id.contains('drag')) return [10, 15, 20];

    if (id.contains('estrella')) return [10, 15, 20];

    if (id.contains('manten') || id.contains('zen')) return [2, 4, 6];

    if (id.contains('double') || id.contains('doble')) return [10, 15, 20];

    return [25, 50, 100];
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().getRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Juega al menos una vez para empezar a desbloquear logros"));
        }
        final records = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final item = records[index];
            String idJuego = item['nombreJuego'] ?? "Juego";
            String nombrePantalla = idJuego.toUpperCase();
            if (idJuego == 'juego8') nombrePantalla = "3 PUERTAS";
            int miPuntuacionMax = item['puntuacion'] as int;
            List<int> metas = _obtenerMetas(idJuego);
            return Container(
              margin: const EdgeInsets.only(bottom: 25),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(nombrePantalla, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      Text("Récord: $miPuntuacionMax", style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _insignia(metas[0], miPuntuacionMax, Colors.brown.shade400, "BRONCE"),
                      _insignia(metas[1], miPuntuacionMax, Colors.blueGrey.shade300, "PLATA"),
                      _insignia(metas[2], miPuntuacionMax, Colors.amber, "ORO"),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Widget _insignia(int meta, int puntuacionActual, Color colorActivo, String nivel) {
    bool desbloqueado = puntuacionActual >= meta;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: desbloqueado ? colorActivo : Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: desbloqueado ? [const BoxShadow(color: Colors.black, offset: Offset(3, 3))] : [],
          ),
          child: Icon(
            desbloqueado ? Icons.emoji_events : Icons.lock,
            color: desbloqueado ? Colors.white : Colors.grey.shade400,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(nivel, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: desbloqueado ? Colors.black : Colors.grey)),
        Text("$meta Pts", style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
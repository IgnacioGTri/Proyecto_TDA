import 'dart:math';
import 'package:flutter/material.dart';
import '../BaseDeDatos/DatabaseHelper.dart';

class Juego8 extends StatefulWidget {
  const Juego8({super.key});

  @override
  State<Juego8> createState() => _Juego8State();
}

class _Juego8State extends State<Juego8> {
  int _puertaPremio = 0;
  int? _puertaElegida;
  int? _puertaReveladaErronea;
  bool _juegoTerminado = false;
  bool _esperandoCambio = false;
  String _mensajeStatus = "Elige una puerta para empezar";

  int _partidasCambiando = 0;
  int _victoriasCambiando = 0;
  int _partidasSinCambiar = 0;
  int _victoriasSinCambiar = 0;

  @override
  void initState() {
    super.initState();
    _iniciarNuevaPartida();
  }

  void _iniciarNuevaPartida() {
    setState(() {
      _puertaPremio = Random().nextInt(3);
      _puertaElegida = null;
      _puertaReveladaErronea = null;
      _juegoTerminado = false;
      _esperandoCambio = false;
      _mensajeStatus = "Elige una puerta donde creas que está el PREMIO";
    });
  }

  void _seleccionarPuertaInicial(int indicePuerta) {
    if (_esperandoCambio || _juegoTerminado) return;

    setState(() {
      _puertaElegida = indicePuerta;
      List<int> puertasPosiblesParaRevelar = [];
      for (int i = 0; i < 3; i++) {
        if (i != _puertaElegida && i != _puertaPremio) {
          puertasPosiblesParaRevelar.add(i);
        }
      }
      _puertaReveladaErronea = puertasPosiblesParaRevelar[Random().nextInt(puertasPosiblesParaRevelar.length)];

      _esperandoCambio = true;
      _mensajeStatus = "Se ha abierto la Puerta ${_puertaReveladaErronea! + 1} y está VACÍA.\n¿Quieres cambiar tu elección?";
    });
  }

  void _resolverJuego(bool cambiarDePuerta) {
    setState(() {
      _esperandoCambio = false;
      _juegoTerminado = true;

      int segundosDeEstaPartida = 15;

      if (cambiarDePuerta) {
        _partidasCambiando++;
        for (int i = 0; i < 3; i++) {
          if (i != _puertaElegida && i != _puertaReveladaErronea) {
            _puertaElegida = i;
            break;
          }
        }

        if (_puertaElegida == _puertaPremio) {
          _victoriasCambiando++;
          _mensajeStatus = "¡GANASTE! Cambiaste a la Puerta ${_puertaElegida! + 1} y tenía el premio. 🏆";
        } else {
          _mensajeStatus = "PERDISTE. Cambiaste a la Puerta ${_puertaElegida! + 1} pero estaba vacía. 😢";
        }
      } else {
        _partidasSinCambiar++;
        if (_puertaElegida == _puertaPremio) {
          _victoriasSinCambiar++;
          _mensajeStatus = "¡GANASTE! Te quedaste con la Puerta ${_puertaElegida! + 1} y tenía el premio. 🏆";
        } else {
          _mensajeStatus = "PERDISTE. La Puerta ${_puertaElegida! + 1} estaba vacía. 😢";
        }
      }
      int totalVictoriasAcumuladas = _victoriasCambiando + _victoriasSinCambiar;
      DatabaseHelper().insertRecord('juego8', totalVictoriasAcumuladas, segundosDeEstaPartida);
    });
  }

  double _calcularPorcentaje(int victorias, int totales) {
    if (totales == 0) return 0.0;
    return (victorias.toDouble() / totales.toDouble()) * 100;
  }

  @override
  Widget build(BuildContext context) {
    double porcCambiando = _calcularPorcentaje(_victoriasCambiando, _partidasCambiando);
    double porcSinCambiar = _calcularPorcentaje(_victoriasSinCambiar, _partidasSinCambiar);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('EL JUEGO DE LAS 3 PUERTAS', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(
                  child: _statCard("Cambiando Puerta", porcCambiando, _victoriasCambiando, _partidasCambiando, Colors.green),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard("Manteniendo Inicial", porcSinCambiar, _victoriasSinCambiar, _partidasSinCambiar, Colors.blue),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              _mensajeStatus,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) => _construirPuerta(index)),
          ),

          const Spacer(),
          if (_esperandoCambio)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                  ]
              ),
              child: Column(
                children: [
                  const Text("¿DESEAS CAMBIAR DE PUERTA?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                        ),
                        onPressed: () => _resolverJuego(true),
                        child: const Text("SÍ, CAMBIAR", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                        ),
                        onPressed: () => _resolverJuego(false),
                        child: const Text("NO, ME QUEDO", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          if (_juegoTerminado)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: _iniciarNuevaPartida,
                  icon: const Icon(Icons.refresh),
                  label: const Text("JUGAR OTRA VEZ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _statCard(String titulo, double porcentaje, int victorias, int totales, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 5),
          Text("${porcentaje.toStringAsFixed(1)}%", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text("$victorias de $totales victorias", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _construirPuerta(int indice) {
    IconData iconoPuerta = Icons.door_front_door;
    Color colorPuerta = Colors.brown.shade400;

    if (_puertaElegida == indice) {
      colorPuerta = Colors.orange;
    }

    if (_puertaReveladaErronea == indice) {
      iconoPuerta = Icons.meeting_room;
      colorPuerta = Colors.grey.shade400;
    }

    if (_juegoTerminado) {
      if (_puertaPremio == indice) {
        iconoPuerta = Icons.emoji_events;
        colorPuerta = Colors.amber;
      } else {
        iconoPuerta = Icons.close;
        colorPuerta = Colors.red.shade200;
      }
    }

    return GestureDetector(
      onTap: () => _seleccionarPuertaInicial(indice),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 160,
            decoration: BoxDecoration(
              color: colorPuerta,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _puertaElegida == indice ? Colors.orange.shade800 : Colors.black,
                width: _puertaElegida == indice ? 4 : 2,
              ),
            ),
            child: Icon(iconoPuerta, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text("Puerta ${indice + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
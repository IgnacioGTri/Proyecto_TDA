import 'package:flutter/material.dart';
import 'dart:async';
import '../BaseDeDatos/DatabaseHelper.dart';

class TapGameWidget extends StatefulWidget {
  const TapGameWidget({Key? key}) : super(key: key);

  @override
  _TapGameWidgetState createState() => _TapGameWidgetState();
}

class _TapGameWidgetState extends State<TapGameWidget> {
  int _contadorTaps = 0;
  int _tiempoRestante = 10;
  bool _jugando = false;
  late DateTime _horaInicioPartida;

  Timer? _timer;

  void _iniciarJuego() {
    setState(() {
      _contadorTaps = 0;
      _tiempoRestante = 10;
      _jugando = true;
      _horaInicioPartida = DateTime.now();
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tiempoRestante > 0) {
        setState(() => _tiempoRestante--);
      } else {
        timer.cancel();
        _terminarJuego();
      }
    });
  }

  void _terminarJuego() async {
    setState(() => _jugando = false);

    final ahora = DateTime.now();
    final segundosJugados = ahora.difference(_horaInicioPartida).inSeconds;

    await DatabaseHelper().insertRecord('Tap Game', _contadorTaps, segundosJugados);

    if (!mounted) return;

    _mostrarDialogoFinal(segundosJugados);
  }

  void _mostrarDialogoFinal(int segundos) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⏱️ ¡TIEMPO!', textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tu puntuación final es:'),
            Text('$_contadorTaps TAPS',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 10),
            const Text('¡Récord actualizado en la base de datos!'),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: const StadiumBorder()),
              onPressed: () => Navigator.pop(context),
              child: const Text('ENTENDIDO', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _sumarTap() {
    if (_jugando) setState(() => _contadorTaps++);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('TAP CHALLENGE',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    const Icon(Icons.info_outline, color: Colors.transparent),
                  ],
                ),
              ),

              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCard('TIEMPO', '$_tiempoRestante s', _tiempoRestante < 4 ? Colors.red : Colors.orange),
                  _statCard('TAPS', '$_contadorTaps', Colors.blue),
                ],
              ),

              const Spacer(),
              GestureDetector(
                onTap: _sumarTap,
                child: AnimatedScale(
                  scale: _jugando ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _jugando ? Colors.orange : Colors.grey.shade300,
                      boxShadow: [
                        BoxShadow(
                          color: (_jugando ? Colors.orange : Colors.grey).withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _jugando ? '¡TAP!' : 'START',
                        style: const TextStyle(fontSize: 35, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _jugando ? null : _iniciarJuego,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('INICIAR', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    IconButton(
                      onPressed: () {
                        _timer?.cancel();
                        setState(() {
                          _contadorTaps = 0;
                          _tiempoRestante = 10;
                          _jugando = false;
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 30),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(15),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}
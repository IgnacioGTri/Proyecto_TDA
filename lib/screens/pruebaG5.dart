import 'dart:async';
import 'package:flutter/material.dart';

class LongPressGame extends StatefulWidget {
  const LongPressGame({Key? key}) : super(key: key);

  @override
  State<LongPressGame> createState() => _LongPressGameState();
}

class _LongPressGameState extends State<LongPressGame> {
  int _aciertos = 0;
  int _fallos = 0;
  int _tiempo = 20;

  bool _jugando = false;

  Timer? _timer;

  DateTime? _inicioPulsacion;

  bool _presionando = false;

  void _start() {
    _timer?.cancel();

    setState(() {
      _aciertos = 0;
      _fallos = 0;
      _tiempo = 20;
      _jugando = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _tiempo--);

      if (_tiempo == 0) {
        t.cancel();
        _finJuego();
      }
    });
  }

  void _reset() {
    _timer?.cancel();

    setState(() {
      _aciertos = 0;
      _fallos = 0;
      _tiempo = 20;
      _jugando = false;
      _presionando = false;
      _inicioPulsacion = null;
    });
  }

  void _finJuego() {
    setState(() {
      _jugando = false;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('⏱️ Fin del juego'),
        content: Text('Aciertos: $_aciertos\nFallos: $_fallos'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // ===================== LONG PRESS START =====================
  void _onLongPressStart() {
    if (!_jugando) return;

    setState(() {
      _presionando = true;
      _inicioPulsacion = DateTime.now();
    });
  }

  // ===================== LONG PRESS END =====================
  void _onLongPressEnd() {
    if (!_jugando) return;

    if (_inicioPulsacion == null) return;

    final duracion =
        DateTime.now().difference(_inicioPulsacion!).inMilliseconds;

    double segundos = duracion / 1000.0;

    bool acierto = segundos >= 2.0 && segundos <= 3.0;

    setState(() {
      if (acierto) {
        _aciertos++;
      } else {
        _fallos++;
      }

      _presionando = false;
      _inicioPulsacion = null;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timing Long Press Game 🎯'),
      ),
      body: Stack(
        children: [
          // ===================== CÍRCULO ÚNICO =====================
          Center(
            child: GestureDetector(
              onLongPressStart: (_) => _onLongPressStart(),
              onLongPressEnd: (_) => _onLongPressEnd(),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: _presionando ? Colors.red : Colors.grey,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'MANTÉN\n2-3s',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),

          // ===================== INFO =====================
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text('⏱️ $_tiempo s',
                    style: const TextStyle(fontSize: 22)),
                Text('✅ Aciertos: $_aciertos',
                    style: const TextStyle(fontSize: 18)),
                Text('❌ Fallos: $_fallos',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),

          // ===================== BOTONES =====================
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _jugando ? null : _start,
                  child: const Text('START'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _reset,
                  child: const Text('RESET'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
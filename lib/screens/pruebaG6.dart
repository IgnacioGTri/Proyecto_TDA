import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DoubleTapGame extends StatefulWidget {
  const DoubleTapGame({Key? key}) : super(key: key);

  @override
  State<DoubleTapGame> createState() => _DoubleTapGameState();
}

class _DoubleTapGameState extends State<DoubleTapGame> {
  int _aciertos = 0;
  int _fallos = 0;
  int _tiempo = 30;

  bool _jugando = false;
  bool _muyLento = false;

  int _circuloVerde = -1;

  Timer? _gameTimer;
  Timer? _targetTimer;

  final Random _random = Random();

  final List<Offset> _posiciones = [
    const Offset(-100, -100),
    const Offset(100, -100),
    const Offset(-100, 100),
    const Offset(100, 100),
  ];

  // ================= START =================
  void _start() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();

    setState(() {
      _aciertos = 0;
      _fallos = 0;
      _tiempo = 30;
      _jugando = true;
      _muyLento = false;
    });

    _nuevoObjetivo();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _tiempo--);

      if (_tiempo == 0) {
        t.cancel();
        _finJuego();
      }
    });
  }

  // ================= RESET =================
  void _reset() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();

    setState(() {
      _jugando = false;
      _aciertos = 0;
      _fallos = 0;
      _tiempo = 30;
      _circuloVerde = -1;
      _muyLento = false;
    });
  }

  // ================= FIN =================
  void _finJuego() {
    _targetTimer?.cancel();

    setState(() {
      _jugando = false;
      _circuloVerde = -1;
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

  // ================= NUEVO OBJETIVO =================
  void _nuevoObjetivo() {
    if (!_jugando) return;

    setState(() {
      _circuloVerde = _random.nextInt(4);
    });

    _targetTimer?.cancel();

    _targetTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!_jugando) return;

      setState(() {
        _fallos++;
        _muyLento = true;
      });

      // Mostrar mensaje 0.5s
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _muyLento = false;
          });
        }
      });

      _nuevoObjetivo();
    });
  }

  // ================= DOUBLE TAP =================
  void _onDoubleTap(int index) {
    if (!_jugando) return;

    _targetTimer?.cancel();

    if (index == _circuloVerde) {
      setState(() => _aciertos++);
    } else {
      setState(() => _fallos++);
    }

    _nuevoObjetivo();
  }

  // ================= CÍRCULO =================
  Widget _circulo(int index) {
    bool esVerde = index == _circuloVerde;

    return Positioned(
      left: MediaQuery.of(context).size.width / 2 +
          _posiciones[index].dx -
          30,
      top: MediaQuery.of(context).size.height / 2 +
          _posiciones[index].dy -
          30,
      child: GestureDetector(
        onDoubleTap: () => _onDoubleTap(index),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: esVerde ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('¡Double TAAAAP!'),
      ),
      body: Stack(
        children: [
          // CÍRCULOS
          for (int i = 0; i < 4; i++) _circulo(i),

          // INFO
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text('Tiempo ⏱️ $_tiempo s',
                    style: const TextStyle(fontSize: 22)),
                Text('✅ Aciertos: $_aciertos',
                    style: const TextStyle(fontSize: 18)),
                Text('❌ Fallos: $_fallos',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),

          // MENSAJE MUY LENTO
          if (_muyLento)
            const Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '¡MUY LENTO!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),

          // BOTONES
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
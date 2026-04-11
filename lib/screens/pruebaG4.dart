import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class StarTapGame extends StatefulWidget {
  const StarTapGame({Key? key}) : super(key: key);

  @override
  State<StarTapGame> createState() => _StarTapGameState();
}

class _StarTapGameState extends State<StarTapGame> {
  int _aciertos = 0;
  int _errores = 0;
  int _tiempo = 20;

  bool _jugando = false;
  bool _respondido = false;
  bool _muyLento = false;

  Timer? _timer;

  int _circuloActivo = -1;
  Color _colorActivo = Colors.transparent;

  final List<Color> _secuencia = [
    Colors.red,
    Colors.blue,
    Colors.green,
  ];

  int _indexColor = 0;

  final Random _random = Random();

  List<Offset> _posiciones = [];

  @override
  void initState() {
    super.initState();
    _generarPosiciones();
  }

  void _generarPosiciones() {
    _posiciones = [
      const Offset(0, -140),
      const Offset(120, -40),
      const Offset(70, 120),
      const Offset(-70, 120),
      const Offset(-120, -40),
    ];
  }

  void _rotarPosiciones() {
    double angulo = _random.nextDouble() * pi;

    setState(() {
      _posiciones = _posiciones.map((p) {
        double x = p.dx * cos(angulo) - p.dy * sin(angulo);
        double y = p.dx * sin(angulo) + p.dy * cos(angulo);
        return Offset(x, y);
      }).toList();
    });
  }

  // ================= START =================
  void _start() {
    _timer?.cancel();

    setState(() {
      _aciertos = 0;
      _errores = 0;
      _tiempo = 20;
      _jugando = true;
      _respondido = false;
      _muyLento = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _tiempo--);

      if (_tiempo == 0) {
        t.cancel();
        _finJuego();
      }
    });

    _nuevoObjetivo();
  }

  // ================= FIN =================
  void _finJuego() {
    setState(() {
      _jugando = false;
      _circuloActivo = -1;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('⏱️ Fin del juego'),
        content: Text('Aciertos: $_aciertos\nErrores: $_errores'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // ================= RESET =================
  void _reset() {
    _timer?.cancel();

    setState(() {
      _aciertos = 0;
      _errores = 0;
      _tiempo = 20;
      _jugando = false;
      _circuloActivo = -1;
      _respondido = false;
      _muyLento = false;
    });
  }

  // ================= NUEVO OBJETIVO =================
  void _nuevoObjetivo() {
    if (!_jugando) return;

    setState(() {
      _circuloActivo = _random.nextInt(5);
      _colorActivo = _secuencia[_indexColor];
      _indexColor = (_indexColor + 1) % _secuencia.length;
      _respondido = false;
    });

    _rotarPosiciones();

    // ⏱️ TIMEOUT 1s
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!_jugando) return;

      if (!_respondido) {
        setState(() {
          _errores++;
          _muyLento = true;
        });

        // 🔴 Mostrar solo 0.5s
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _muyLento = false;
            });
          }
        });
      }

      _nuevoObjetivo();
    });
  }

  // ================= TAP =================
  void _onTap(int index) {
    if (!_jugando) return;

    if (index == _circuloActivo) {
      _aciertos++;
      _respondido = true;
    } else {
      _errores++;
    }

    setState(() {});
  }

  // ================= CÍRCULO =================
  Widget _circulo(int index) {
    bool activo = index == _circuloActivo;

    return Positioned(
      left: MediaQuery.of(context).size.width / 2 +
          _posiciones[index].dx -
          30,
      top: MediaQuery.of(context).size.height / 2 +
          _posiciones[index].dy -
          30,
      child: GestureDetector(
        onTapDown: (_) => _onTap(index),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: activo ? _colorActivo : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '¡EstrellaDoS ⭐!',
          style: TextStyle(fontSize: 24, color: Colors.red),
        ),
      ),
      body: Stack(
        children: [
          // CÍRCULOS
          for (int i = 0; i < 5; i++) _circulo(i),

          // INFO
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text('⏱️ Tiempo: $_tiempo s',
                    style: const TextStyle(fontSize: 22)),
                Text('✅ Aciertos: $_aciertos',
                    style: const TextStyle(fontSize: 18)),
                Text('❌ Errores: $_errores',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),

          // 🔴 MENSAJE MUY LENTO
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
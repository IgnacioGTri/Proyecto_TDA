import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DragShapesGame extends StatefulWidget {
  const DragShapesGame({Key? key}) : super(key: key);

  @override
  State<DragShapesGame> createState() => _DragShapesGameState();
}

class _DragShapesGameState extends State<DragShapesGame> {
  int _aciertos = 0;
  int _errores = 0;
  int _tiempo = 30;

  bool _jugando = false;
  bool _muyLento = false;

  String _objetivo = '';
  Timer? _gameTimer;
  Timer? _roundTimer;

  final Random _random = Random();

  final List<String> _formas = [
    'circulo',
    'triangulo',
    'cuadrado',
    'hexagono'
  ];

  List<Offset> _posiciones = [];

  @override
  void initState() {
    super.initState();
    _generarPosiciones();
  }

  void _generarPosiciones() {
    _posiciones = [
      const Offset(-100, -100),
      const Offset(100, -100),
      const Offset(-100, 100),
      const Offset(100, 100),
    ]..shuffle();
  }

  // ================= START =================
  void _start() {
    _gameTimer?.cancel();
    _roundTimer?.cancel();

    setState(() {
      _aciertos = 0;
      _errores = 0;
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

  void _reset() {
    _gameTimer?.cancel();
    _roundTimer?.cancel();

    setState(() {
      _jugando = false;
      _aciertos = 0;
      _errores = 0;
      _tiempo = 30;
      _muyLento = false;
      _objetivo = '';
    });
  }

  void _finJuego() {
    _roundTimer?.cancel();

    setState(() {
      _jugando = false;
      _objetivo = '';
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

  void _nuevoObjetivo() {
    if (!_jugando) return;

    setState(() {
      _objetivo = _formas[_random.nextInt(_formas.length)];
      _generarPosiciones();
    });

    _roundTimer?.cancel();
    _roundTimer = Timer(const Duration(seconds: 2), () {
      if (!_jugando) return;

      setState(() {
        _errores++;
        _muyLento = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _muyLento = false);
        }
      });

      _nuevoObjetivo();
    });
  }

  void _onDrop(String forma) {
    if (!_jugando) return;

    _roundTimer?.cancel();

    if (forma == _objetivo) {
      _aciertos++;
    } else {
      _errores++;
    }

    setState(() {});
    _nuevoObjetivo();
  }

  // ================= SHAPE PAINTER =================
  Color _getColor(String shape) {
    switch (shape) {
      case 'circulo':
        return Colors.red;
      case 'triangulo':
        return Colors.green;
      case 'cuadrado':
        return Colors.blue;
      case 'hexagono':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _shape(String shape, double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: ShapePainter(shape, _getColor(shape)),
    );
  }

  // ================= ZONA =================
  Widget _zona(String forma, int index) {
    return Positioned(
      left: MediaQuery.of(context).size.width / 2 +
          _posiciones[index].dx -
          40,
      top: MediaQuery.of(context).size.height / 2 +
          _posiciones[index].dy -
          40,
      child: DragTarget<String>(
        onAccept: (_) => _onDrop(forma),
        builder: (_, __, ___) {
          return SizedBox(
            width: 80,
            height: 80,
            child: _shape(forma, 80),
          );
        },
      ),
    );
  }

  // ================= DRAG =================
  Widget _pieza() {
    if (!_jugando || _objetivo.isEmpty) return const SizedBox();

    return Draggable<String>(
      data: _objetivo,
      feedback: Material(
        color: Colors.transparent,
        child: _shape(_objetivo, 60),
      ),
      child: _shape(_objetivo, 60),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _roundTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Arrastra la forma',
          style: TextStyle(fontSize: 24, color: Colors.red),
        ),
      ),
      body: Stack(
        children: [
          for (int i = 0; i < 4; i++) _zona(_formas[i], i),

          Center(child: _pieza()),

          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text('Tiempo: ⏱️ $_tiempo s'),
                Text('Aciertos ✅ $_aciertos'),
                Text('Fallos ❌ $_errores'),
              ],
            ),
          ),

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
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

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
                  child: const Text('REINICIAR'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CUSTOM PAINTER =================
class ShapePainter extends CustomPainter {
  final String shape;
  final Color color;

  ShapePainter(this.shape, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    switch (shape) {
      case 'circulo':
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.width / 2,
          paint,
        );
        break;

      case 'cuadrado':
        canvas.drawRect(
          Rect.fromLTWH(2, 2, size.width, size.height),
          paint,
        );
        break;

      case 'triangulo':
        path.moveTo(size.width / 2, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case 'hexagono':
        final w = size.width;
        final h = size.height;

        path.moveTo(w * 0.25, 0);
        path.lineTo(w * 0.75, 0);
        path.lineTo(w, h * 0.5);
        path.lineTo(w * 0.75, h);
        path.lineTo(w * 0.25, h);
        path.lineTo(0, h * 0.5);
        path.close();

        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
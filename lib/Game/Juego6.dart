import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../BaseDeDatos/DatabaseHelper.dart';

class DragShapesGame extends StatefulWidget {
  const DragShapesGame({Key? key}) : super(key: key);

  @override
  State<DragShapesGame> createState() => _DragShapesGameState();
}

class _DragShapesGameState extends State<DragShapesGame> {
  int _aciertos = 0;
  int _errores = 0;
  // 🔥 Ajustado a 20 segundos de base
  int _tiempo = 20;

  bool _jugando = false;
  bool _muyLento = false;
  late DateTime _horaInicioPartida;

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

  List<Alignment> _posiciones = [];

  @override
  void initState() {
    super.initState();
    _generarPosiciones();
  }

  void _generarPosiciones() {
    _posiciones = [
      const Alignment(-0.9, -0.9),
      const Alignment(0.9, -0.9),
      const Alignment(-0.9, 0.9),
      const Alignment(0.9, 0.9),
    ]..shuffle();
  }

  void _start() {
    _gameTimer?.cancel();
    _roundTimer?.cancel();

    setState(() {
      _aciertos = 0;
      _errores = 0;
      // 🔥 Ajustado a 20 segundos al darle a START
      _tiempo = 20;
      _jugando = true;
      _muyLento = false;
      _horaInicioPartida = DateTime.now();
    });

    _nuevoObjetivo();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_tiempo > 0) {
        setState(() => _tiempo--);
      } else {
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
      // 🔥 Ajustado a 20 segundos al darle a RESET
      _tiempo = 20;
      _muyLento = false;
      _objetivo = '';
    });
  }

  void _finJuego() async {
    _roundTimer?.cancel();
    setState(() {
      _jugando = false;
      _objetivo = '';
    });

    final segundosJugados = DateTime.now().difference(_horaInicioPartida).inSeconds;
    await DatabaseHelper().insertRecord('Arrastra Formas', _aciertos, segundosJugados);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('⏱️ ¡FIN!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_aciertos', style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const Text('Formas encajadas', style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context),
              child: const Text('GENIAL', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
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
    _roundTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted || !_jugando) return;

      setState(() {
        _errores++;
        _muyLento = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _muyLento = false);
      });

      _nuevoObjetivo();
    });
  }

  void _onDrop(String forma) {
    if (!_jugando) return;

    _roundTimer?.cancel();

    setState(() {
      if (forma == _objetivo) {
        _aciertos++;
      } else {
        _errores++;
      }
    });

    _nuevoObjetivo();
  }

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
      backgroundColor: const Color(0xFF161625),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A2A40), Color(0xFF161625)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _customAppBar(),
              _scoreBoard(),

              const Spacer(),

              SizedBox(
                width: 320,
                height: 320,
                child: Stack(
                  children: [
                    for (int i = 0; i < 4; i++) _zonaDestino(_formas[i], i),

                    Center(child: _pieza()),

                    if (_muyLento)
                      const Center(
                        child: Text(
                          '¡LENTO!',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.redAccent, shadows: [Shadow(color: Colors.red, blurRadius: 15)]),
                        ),
                      ),
                  ],
                ),
              ),

              const Spacer(),
              _bottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customAppBar() => Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
        const Text('SHAPE MATCH', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.blueAccent, letterSpacing: 2)),
        const SizedBox(width: 40),
      ],
    ),
  );

  Widget _scoreBoard() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _statCard('TIEMPO', '$_tiempo s', _tiempo < 6 ? Colors.redAccent : Colors.white),
      _statCard('ACIERTOS', '$_aciertos', Colors.greenAccent),
      _statCard('FALLOS', '$_errores', Colors.redAccent),
    ],
  );

  Widget _statCard(String label, String value, Color color) => Container(
    width: 100, padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white12)),
    child: Column(children: [Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)), const SizedBox(height: 5), Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color))]),
  );

  Widget _bottomButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _jugando ? null : _start,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: const Text('START', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
        const SizedBox(width: 15),
        IconButton(
          onPressed: _reset,
          icon: const Icon(Icons.refresh, size: 30, color: Colors.white),
          style: IconButton.styleFrom(backgroundColor: Colors.white10, padding: const EdgeInsets.all(15)),
        )
      ],
    ),
  );

  Widget _zonaDestino(String forma, int index) {
    return Align(
      alignment: _posiciones[index],
      child: DragTarget<String>(
        onAccept: (_) => _onDrop(forma),
        builder: (context, candidateData, rejectedData) {
          return Opacity(
            opacity: 0.3,
            child: SizedBox(
              width: 80, height: 80,
              child: _shape(forma, 80),
            ),
          );
        },
      ),
    );
  }

  Color _getColor(String shape) {
    switch (shape) {
      case 'circulo': return Colors.redAccent;
      case 'triangulo': return Colors.greenAccent;
      case 'cuadrado': return Colors.blueAccent;
      case 'hexagono': return Colors.purpleAccent;
      default: return Colors.grey;
    }
  }

  Widget _shape(String shape, double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: ShapePainter(shape, _getColor(shape)),
    );
  }
}

class ShapePainter extends CustomPainter {
  final String shape;
  final Color color;

  ShapePainter(this.shape, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();

    switch (shape) {
      case 'circulo':
        canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
        break;
      case 'cuadrado':
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(8)), paint);
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
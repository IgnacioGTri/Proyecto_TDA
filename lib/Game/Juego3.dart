import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../BaseDeDatos/DatabaseHelper.dart'; // Asegúrate de que la ruta sea correcta

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
  late DateTime _horaInicioPartida;

  Timer? _timer;
  int _circuloActivo = -1;
  Color _colorActivo = Colors.transparent;

  final List<Color> _secuencia = [
    Colors.redAccent,
    Colors.lightBlueAccent,
    Colors.greenAccent,
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
      const Offset(0, -120),
      const Offset(110, -35),
      const Offset(70, 100),
      const Offset(-70, 100),
      const Offset(-110, -35),
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

  void _start() {
    _timer?.cancel();

    setState(() {
      _aciertos = 0;
      _errores = 0;
      _tiempo = 20;
      _jugando = true;
      _respondido = false;
      _muyLento = false;
      _horaInicioPartida = DateTime.now();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_tiempo > 0) {
        setState(() => _tiempo--);
      } else {
        t.cancel();
        _finJuego();
      }
    });

    _nuevoObjetivo();
  }

  void _finJuego() async {
    setState(() {
      _jugando = false;
      _circuloActivo = -1;
    });

    // Guardar en la Base de Datos
    final segundosJugados = DateTime.now().difference(_horaInicioPartida).inSeconds;
    await DatabaseHelper().insertRecord('Estrellas', _aciertos, segundosJugados);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⏱️ ¡FIN DEL JUEGO!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_aciertos', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.amber)),
            const Text('Estrellas cazadas'),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, shape: const StadiumBorder()),
              onPressed: () => Navigator.pop(context),
              child: const Text('GENIAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

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

  void _nuevoObjetivo() {
    if (!_jugando) return;

    setState(() {
      _circuloActivo = _random.nextInt(5);
      _colorActivo = _secuencia[_indexColor];
      _indexColor = (_indexColor + 1) % _secuencia.length;
      _respondido = false;
    });

    _rotarPosiciones();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted || !_jugando) return;

      if (!_respondido) {
        setState(() {
          _errores++;
          _muyLento = true;
        });

        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _muyLento = false);
        });
      }
      _nuevoObjetivo();
    });
  }

  void _onTap(int index) {
    if (!_jugando || _respondido) return; // Evita doble toque

    if (index == _circuloActivo) {
      setState(() {
        _aciertos++;
        _respondido = true;
        _circuloActivo = -1; // Lo apagamos al tocarlo
      });
    } else {
      setState(() => _errores++);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10), // Fondo muy oscuro (espacial)
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF1F2833), Color(0xFF0B0C10)],
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _customAppBar(),
              _scoreBoard(),

              const Spacer(),

              // CONTENEDOR CENTRAL: Aquí ocurre la magia de la rotación
              SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // El Sol/Centro decorativo
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white10,
                        border: Border.all(color: Colors.white24),
                      ),
                    ),
                    // Los círculos giratorios
                    for (int i = 0; i < 5; i++) _circuloEstrella(i),

                    // Alerta de MUY LENTO
                    if (_muyLento)
                      const Center(
                        child: Text(
                          '¡LENTO!',
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w900,
                            color: Colors.redAccent,
                            shadows: [Shadow(color: Colors.red, blurRadius: 15)],
                          ),
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

  // --- WIDGETS UI ---

  Widget _customAppBar() => Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
        const Text('ESTRELLAS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
        const SizedBox(width: 40),
      ],
    ),
  );

  Widget _scoreBoard() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _statCard('TIEMPO', '$_tiempo s', _tiempo < 6 ? Colors.redAccent : Colors.cyanAccent),
      _statCard('SCORE', '$_aciertos', Colors.amberAccent),
    ],
  );

  Widget _statCard(String label, String value, Color color) => Container(
    width: 130, padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white12)),
    child: Column(children: [Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)), const SizedBox(height: 5), Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color))]),
  );

  Widget _bottomButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _jugando ? null : _start,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
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

  Widget _circuloEstrella(int index) {
    bool activo = index == _circuloActivo;

    return Positioned(
      // 150 es el centro del SizedBox de 300x300, menos 35 (mitad del tamaño del círculo)
      left: 150 + _posiciones[index].dx - 35,
      top: 150 + _posiciones[index].dy - 35,
      child: GestureDetector(
        onTapDown: (_) => _onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 70, // Círculos un poco más grandes (eran 60)
          height: 70,
          decoration: BoxDecoration(
            color: activo ? _colorActivo : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: activo ? _colorActivo.withOpacity(0.8) : Colors.white24,
              width: activo ? 4 : 1,
            ),
            boxShadow: [
              if (activo) BoxShadow(color: _colorActivo.withOpacity(0.6), blurRadius: 20, spreadRadius: 5)
            ],
          ),
          child: activo
              ? const Icon(Icons.star_rounded, color: Colors.white, size: 40)
              : null,
        ),
      ),
    );
  }
}
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../BaseDeDatos/DatabaseHelper.dart';

class DoubleTapGame extends StatefulWidget {
  const DoubleTapGame({Key? key}) : super(key: key);

  @override
  State<DoubleTapGame> createState() => _DoubleTapGameState();
}

class _DoubleTapGameState extends State<DoubleTapGame> {
  int _aciertos = 0;
  int _fallos = 0;
  int _tiempo = 20;
  bool _jugando = false;
  bool _muyLento = false;
  late DateTime _horaInicioPartida;
  int _circuloActivo = -1;
  Timer? _gameTimer;
  Timer? _targetTimer;
  final Random _random = Random();
  void _start() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();
    setState(() {
      _aciertos = 0;
      _fallos = 0;
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
    _targetTimer?.cancel();
    setState(() {
      _jugando = false;
      _aciertos = 0;
      _fallos = 0;
      _tiempo = 20;
      _circuloActivo = -1;
      _muyLento = false;
    });
  }

  void _finJuego() async {
    _targetTimer?.cancel();

    setState(() {
      _jugando = false;
      _circuloActivo = -1;
    });
    final segundosJugados = DateTime.now().difference(_horaInicioPartida).inSeconds;
    await DatabaseHelper().insertRecord('Double Tap', _aciertos, segundosJugados);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E102E),
        title: const Text('⏱️ ¡FIN!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_aciertos', style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
            const Text('Dobles Taps conseguidos', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Text('Fallos: $_fallos', style: const TextStyle(color: Colors.redAccent)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black, shape: const StadiumBorder()),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
  void _nuevoObjetivo() {
    if (!_jugando) return;
    setState(() {
      _circuloActivo = _random.nextInt(4);
    });
    _targetTimer?.cancel();
    _targetTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted || !_jugando) return;

      setState(() {
        _fallos++;
        _muyLento = true;
      });

      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _muyLento = false);
      });

      _nuevoObjetivo();
    });
  }

  void _onDoubleTap(int index) {
    if (!_jugando) return;

    _targetTimer?.cancel();

    setState(() {
      if (index == _circuloActivo) {
        _aciertos++;
        _circuloActivo = -1;
      } else {
        _fallos++;
      }
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _nuevoObjetivo();
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _targetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130920),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2B1055), Color(0xFF130920)],
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
                    Center(
                      child: Container(
                        width: 250, height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white10, width: 2),
                        ),
                      ),
                    ),
                    _circulo(0, const Alignment(-0.8, -0.8)),
                    _circulo(1, const Alignment(0.8, -0.8)),
                    _circulo(2, const Alignment(-0.8, 0.8)),
                    _circulo(3, const Alignment(0.8, 0.8)),


                    if (_muyLento)
                      const Center(
                        child: Text(
                          '¡LENTO!',
                          style: TextStyle(
                            fontSize: 40,
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
  Widget _customAppBar() => Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
        const Text('DOUBLE TAAAP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.purpleAccent, letterSpacing: 2)),
        const SizedBox(width: 40),
      ],
    ),
  );

  Widget _scoreBoard() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _statCard('TIEMPO', '$_tiempo s', _tiempo < 6 ? Colors.redAccent : Colors.white),
      _statCard('ACIERTOS', '$_aciertos', Colors.greenAccent),
      _statCard('FALLOS', '$_fallos', Colors.redAccent),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, foregroundColor: Colors.white, padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
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

  Widget _circulo(int index, Alignment alignment) {
    bool activo = index == _circuloActivo;

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onDoubleTap: () => _onDoubleTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: activo ? Colors.greenAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: activo ? Colors.greenAccent : Colors.white24,
              width: activo ? 4 : 2,
            ),
            boxShadow: [
              if (activo) BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
            ],
          ),
          child: Center(
            child: Icon(
              Icons.touch_app, // Icono de tocar
              color: activo ? Colors.greenAccent : Colors.white24,
              size: activo ? 40 : 30,
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import '../BaseDeDatos/DatabaseHelper.dart';

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
  bool _presionando = false;

  String _mensajeFeedback = "MANTÉN\n2-3s";
  Color _colorFeedback = Colors.white;

  Timer? _timer;
  DateTime? _inicioPulsacion;
  late DateTime _horaInicioPartida;

  void _start() {
    _timer?.cancel();

    setState(() {
      _aciertos = 0;
      _fallos = 0;
      _tiempo = 20;
      _jugando = true;
      _presionando = false;
      _mensajeFeedback = "MANTÉN\n2-3s";
      _colorFeedback = Colors.white;
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
      _mensajeFeedback = "MANTÉN\n2-3s";
      _colorFeedback = Colors.white;
    });
  }

  void _finJuego() async {
    setState(() => _jugando = false);

    // Guardar en la Base de Datos
    final segundosJugados = DateTime.now().difference(_horaInicioPartida).inSeconds;
    await DatabaseHelper().insertRecord('Tag 2 ZEN', _aciertos, segundosJugados);

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
            Text('$_aciertos', style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.tealAccent)),
            const Text('Aciertos logrados', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Text('Fallos: $_fallos', style: const TextStyle(color: Colors.redAccent)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black, shape: const StadiumBorder()),
              onPressed: () => Navigator.pop(context),
              child: const Text('RESPIRA Y SAL', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // ===================== LOGICA LONG PRESS =====================
  void _onLongPressStart() {
    if (!_jugando) return;

    setState(() {
      _presionando = true;
      _inicioPulsacion = DateTime.now();
      _mensajeFeedback = "RESPIRA...";
      _colorFeedback = Colors.white54;
    });
  }

  void _onLongPressEnd() {
    if (!_jugando || _inicioPulsacion == null) return;

    final duracion = DateTime.now().difference(_inicioPulsacion!).inMilliseconds;
    double segundos = duracion / 1000.0;
    bool acierto = segundos >= 2.0 && segundos <= 3.0;

    setState(() {
      if (acierto) {
        _aciertos++;
        _mensajeFeedback = "¡PERFECTO!";
        _colorFeedback = Colors.tealAccent;
      } else {
        _fallos++;
        _mensajeFeedback = segundos < 2.0 ? "MUY RÁPIDO" : "TE PASASTE";
        _colorFeedback = Colors.redAccent;
      }
      _presionando = false;
      _inicioPulsacion = null;
    });

    // Volver al texto original después de 1 segundo
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_presionando && _jugando) {
        setState(() {
          _mensajeFeedback = "MANTÉN\n2-3s";
          _colorFeedback = Colors.white;
        });
      }
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
      backgroundColor: const Color(0xFF12121E), // Fondo oscuro
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A1B3D), Color(0xFF12121E)], // Púrpura Zen a Oscuro
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _customAppBar(),
              _scoreBoard(),

              const Spacer(),

              // ===================== ÁREA DE JUEGO =====================
              GestureDetector(
                onLongPressStart: (_) => _onLongPressStart(),
                onLongPressEnd: (_) => _onLongPressEnd(),
                // Usamos onLongPressCancel por si el usuario desliza el dedo fuera accidentalmente
                onLongPressCancel: () {
                  if (_presionando) _onLongPressEnd();
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: _presionando ? 3000 : 300), // Crece lento (3s), se encoge rápido (0.3s)
                  curve: _presionando ? Curves.easeOut : Curves.easeIn,
                  width: _presionando ? 260 : 180,
                  height: _presionando ? 260 : 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _presionando ? Colors.tealAccent.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                    border: Border.all(
                        color: _presionando ? Colors.tealAccent : Colors.white24,
                        width: _presionando ? 6 : 2
                    ),
                    boxShadow: [
                      if (_presionando) BoxShadow(color: Colors.tealAccent.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)
                    ],
                  ),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                          color: _colorFeedback,
                          fontSize: _presionando ? 28 : 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2
                      ),
                      textAlign: TextAlign.center,
                      child: Text(_mensajeFeedback),
                    ),
                  ),
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

  // --- WIDGETS UI MODULARES ---

  Widget _customAppBar() => Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
        const Text('TAG 2 ZEN', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.tealAccent, letterSpacing: 2)),
        const SizedBox(width: 40),
      ],
    ),
  );

  Widget _scoreBoard() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statCard('TIEMPO', '$_tiempo', _tiempo < 6 ? Colors.redAccent : Colors.tealAccent),
        _statCard('ACIERTOS', '$_aciertos', Colors.greenAccent),
        _statCard('FALLOS', '$_fallos', Colors.redAccent),
      ],
    ),
  );

  Widget _statCard(String label, String value, Color color) => Container(
    width: 100, padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white12)),
    child: Column(children: [Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)), const SizedBox(height: 5), Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color))]),
  );

  Widget _bottomButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _jugando ? null : _start,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black, padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
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
}
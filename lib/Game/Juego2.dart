import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../BaseDeDatos/DatabaseHelper.dart';

class DragGameWidget extends StatefulWidget {
  const DragGameWidget({Key? key}) : super(key: key);
  @override
  _DragGameWidgetState createState() => _DragGameWidgetState();
}
class _DragGameWidgetState extends State<DragGameWidget> {
  String _mensaje = '¿LISTO?';
  String _objetivo = '';
  int _aciertos = 0;
  int _errores = 0;
  int _tiempo = 20;
  bool _jugando = false;
  bool _gestoProcesado = false;
  late DateTime _horaInicioPartida;

  Timer? _timer;
  final List<String> _esquinas = ['↖️', '↗️', '↙️', '↘️'];

  @override
  void initState() {
    super.initState();
    _nuevoObjetivo();
  }

  void _nuevoObjetivo() {
    setState(() {
      _objetivo = _esquinas[Random().nextInt(_esquinas.length)];
      _gestoProcesado = false;
    });
  }

  void _start() {
    setState(() {
      _aciertos = 0;
      _errores = 0;
      _tiempo = 20;
      _jugando = true;
      _mensaje = '¡DALE!';
      _horaInicioPartida = DateTime.now();
    });
    _nuevoObjetivo();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tiempo > 0) {
        setState(() => _tiempo--);
      } else {
        timer.cancel();
        _finJuego();
      }
    });
  }

  void _finJuego() async {
    setState(() => _jugando = false);
    final segundosJugados = DateTime.now().difference(_horaInicioPartida).inSeconds;
    await DatabaseHelper().insertRecord('Drag Game', _aciertos, segundosJugados);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⏱️ ¡FIN!', textAlign: TextAlign.center),
        content: Text('Puntos: $_aciertos', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [Center(child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('OK')))],
      ),
    );
  }
  void _detectarMovimiento(DragUpdateDetails details) {
    if (!_jugando || _gestoProcesado) return;
    double dx = details.localPosition.dx - 100;
    double dy = details.localPosition.dy - 100;
    String direccion = '';
    double umbral = 40.0;

    if (dx.abs() > umbral || dy.abs() > umbral) {
      if (dx < -umbral && dy < -umbral) direccion = '↖️';
      if (dx > umbral && dy < -umbral) direccion = '↗️';
      if (dx < -umbral && dy > umbral) direccion = '↙️';
      if (dx > umbral && dy > umbral) direccion = '↘️';

      if (direccion != '') {
        _gestoProcesado = true;
        setState(() {
          if (direccion == _objetivo) {
            _aciertos++;
            _mensaje = '✅ ¡SÍ!';
          } else {
            _errores++;
            _mensaje = '❌ ¡NO!';
          }
        });
        Future.delayed(const Duration(milliseconds: 300), _nuevoObjetivo);
      }
    }
  }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.white], begin: Alignment.topCenter)),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _header(),
                  _stats(),
                  const Spacer(),
                  GestureDetector(
                    onPanUpdate: _detectarMovimiento,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _jugando ? Colors.blue.withOpacity(0.1) : Colors.grey.shade200,
                        border: Border.all(color: _jugando ? Colors.blue : Colors.grey, width: 4),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.open_with_rounded, size: 50, color: _jugando ? Colors.blue : Colors.grey),
                          Text(_mensaje, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  _controles(),
                ],
              ),
              _meta(Alignment.topLeft, '↖️'),
              _meta(Alignment.topRight, '↗️'),
              _meta(Alignment.bottomLeft, '↙️'),
              _meta(Alignment.bottomRight, '↘️'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => Padding(padding: const EdgeInsets.all(20), child: Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios)), const Text('DRAG GAME', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]));

  Widget _stats() => Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
    _card('TIEMPO', '$_tiempo', Colors.orange),
    _card('SCORE', '$_aciertos', Colors.blue),
  ]);

  Widget _card(String t, String v, Color c) => Container(width: 100, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]), child: Column(children: [Text(t, style: const TextStyle(fontSize: 10)), Text(v, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c))]));

  Widget _meta(Alignment a, String id) {
    bool activo = id == _objetivo && _jugando;
    return Align(alignment: a, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 150), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.all(10), decoration: BoxDecoration(shape: BoxShape.circle, color: activo ? Colors.blue : Colors.transparent, border: Border.all(color: activo ? Colors.blue : Colors.grey.shade300)), child: Text(id, style: const TextStyle(fontSize: 25)))));
  }
  Widget _controles() => Padding(padding: const EdgeInsets.all(40), child: Row(children: [Expanded(child: ElevatedButton(onPressed: _jugando ? null : _start, style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white), child: const Text('START'))), const SizedBox(width: 10), IconButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DragGameWidget())), icon: const Icon(Icons.refresh))]));
}
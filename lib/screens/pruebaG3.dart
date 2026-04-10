import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class DragGameWidget extends StatefulWidget {
  const DragGameWidget({Key? key}) : super(key: key);

  @override
  _DragGameWidgetState createState() => _DragGameWidgetState();
}

class _DragGameWidgetState extends State<DragGameWidget> {
  String _mensaje = 'Pulsa START para jugar';
  String _objetivo = '';

  int _aciertos = 0;
  int _errores = 0;
  int _tiempo = 20;

  bool _jugando = false;

  Timer? _timer;

  final List<String> _esquinas = ['↖️', '↗️', '↙️', '↘️'];

  @override
  void initState() {
    super.initState();
    _nuevoObjetivo();
  }

  void _nuevoObjetivo() {
    _objetivo = _esquinas[Random().nextInt(_esquinas.length)];
  }

  void _start() {
    setState(() {
      _aciertos = 0;
      _errores = 0;
      _tiempo = 20;
      _jugando = true;
      _mensaje = '¡Corre!';
    });

    _nuevoObjetivo();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _tiempo--;
      });

      if (_tiempo == 0) {
        timer.cancel();
        _finJuego();
      }
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
        content: Text(
          'Aciertos: $_aciertos\nErrores: $_errores',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
      _mensaje = 'Pulsa START para jugar';
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_jugando) return;

    final v = details.velocity.pixelsPerSecond;
    String direccion = '';

    if (v.dx < 0 && v.dy < 0) direccion = '↖️';
    if (v.dx > 0 && v.dy < 0) direccion = '↗️';
    if (v.dx < 0 && v.dy > 0) direccion = '↙️';
    if (v.dx > 0 && v.dy > 0) direccion = '↘️';

    setState(() {
      if (direccion == _objetivo) {
        _aciertos++;
        _mensaje = '✅ Correcto';
      } else {
        _errores++;
        _mensaje = '❌ Fallo';
      }
    });

    _nuevoObjetivo();
  }

  Widget _circulo(String esquina) {
    bool esObjetivo = esquina == _objetivo;

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: esObjetivo ? Colors.red : Colors.grey,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        esquina,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
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
        centerTitle: true,
        title: const Text('¡Arrástrame esta!',
            style: TextStyle(fontSize: 24, color:Colors.red)),
      ),
      body: Stack(
        children: [
          // Esquinas
          Positioned(top: 170, left: 20, child: _circulo('↖️')),
          Positioned(top: 170, right: 20, child: _circulo('↗️')),
          Positioned(bottom: 170, left: 20, child: _circulo('↙️')),
          Positioned(bottom: 170, right: 20, child: _circulo('↘️')),

          // Centro
          Center(
            child: GestureDetector(
              onPanEnd: _onDragEnd,
              child: Container(
                width: 200,
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _jugando ? Colors.orange : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Arrastra al rojo 🎯',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),

          // Info arriba
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text('⏱️ Tiempo: $_tiempo',
                    style: const TextStyle(fontSize: 20)),
                Text('✅ Aciertos: $_aciertos',
                    style: const TextStyle(fontSize: 18)),
                Text('❌ Errores: $_errores',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),

          // Mensaje
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _mensaje,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          // Botones
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
import 'package:flutter/material.dart';
import 'dart:async';

class TapGameWidget extends StatefulWidget {
  const TapGameWidget({Key? key}) : super(key: key);

  @override
  _TapGameWidgetState createState() => _TapGameWidgetState();
}

class _TapGameWidgetState extends State<TapGameWidget> {
  int _contadorTaps = 0;
  int _tiempoRestante = 10;
  bool _jugando = false;

  Timer? _timer;

  void _iniciarJuego() {
    setState(() {
      _contadorTaps = 0;
      _tiempoRestante = 10;
      _jugando = true;
    });

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _tiempoRestante--;
      });

      if (_tiempoRestante == 0) {
        timer.cancel();
        _terminarJuego();
      }
    });
  }

  void _terminarJuego() {
    setState(() {
      _jugando = false;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('⏱️ Tiempo terminado'),
          content: Text(
            'Has hecho $_contadorTaps taps en 10 segundos 👆🔥',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _sumarTap() {
    if (_jugando) {
      setState(() {
        _contadorTaps++;
      });
    }
  }

  void _resetearJuego() {
    _timer?.cancel();

    setState(() {
      _contadorTaps = 0;
      _tiempoRestante = 10;
      _jugando = false;
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
        centerTitle: true,
        title: const Text('Tap, Tap, ¡TAP!',
        style: TextStyle(fontSize: 24, color:Colors.red),
        ),

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Tiempo: $_tiempoRestante s',
                style: const TextStyle(fontSize: 24)),

            const SizedBox(height: 20),

            Text('Taps: $_contadorTaps',
                style: const TextStyle(fontSize: 24)),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: _sumarTap,
              child: Container(
                width: 200,
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _jugando ? Colors.blue : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _jugando ? '¡TAP!' : 'Pulsa START',
                  style: const TextStyle(
                      fontSize: 22, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🔘 BOTONES
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _jugando ? null : _iniciarJuego,
                  child: const Text('START'),
                ),

                const SizedBox(width: 20),

                ElevatedButton(
                  onPressed: _resetearJuego,
                  child: const Text('RESET'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
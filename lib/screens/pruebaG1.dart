import 'package:flutter/material.dart';

class GestureHomeWidget2 extends StatefulWidget {
  const GestureHomeWidget2({Key? key}) : super(key: key);

  @override
  _GestureHomeWidget2State createState() => _GestureHomeWidget2State();
}

class _GestureHomeWidget2State extends State<GestureHomeWidget2> {
  String _log = '';
  bool _primerDialogo = true;

  int _contadorSegundoDialogo = 0; // 👈 contador

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void _clearLog() {
    setState(() {
      _log = '';
      _controller.text = '';
      _contadorSegundoDialogo = 0; // reset también
    });
  }

  void _escribirLog(String logText) {
    setState(() {
      _log += "\n$logText";
      _controller.text = _log;
    });
  }

  void _mostrarDialogo() {
    bool esSegundo = !_primerDialogo;

    // 👉 Si es el segundo, incrementamos
    if (esSegundo) {
      _contadorSegundoDialogo++;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mensaje'),
          content: Text(
            _primerDialogo
                ? 'Este es el PRIMER diálogo'
                : 'Este es el SEGUNDO diálogo\n\n'
                'Lo has visto $_contadorSegundoDialogo veces 😎',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );

    // alternamos estado
    setState(() {
      _primerDialogo = !_primerDialogo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestures"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onDoubleTap: () {
                _escribirLog('double tap');
                _mostrarDialogo();
              },
              child: const Text(
                'Tócame dos veces 👆',
                style: TextStyle(fontSize: 22),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Segundo diálogo visto: $_contadorSegundoDialogo veces',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 300,
              child: TextField(
                maxLines: 10,
                controller: _controller,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Log de gestos',
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: _clearLog,
              child: const Text('RESETEAR'),
            ),
          ],
        ),
      ),
    );
  }
}
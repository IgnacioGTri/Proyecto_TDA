import 'package:flutter/material.dart';

class GestureHomeWidget extends StatefulWidget {
  const GestureHomeWidget({Key? key}) : super(key: key);

  @override
  _gestureHomeWidgetState createState() => new _gestureHomeWidgetState();
}

class _gestureHomeWidgetState extends State<GestureHomeWidget> {
  String _log = '';

  void _clearLog() {
    setState(() {
      _log = '';
    });
  }

  void _escribirLog(String logText) {
    setState(() {
      _log += "\n";
      _log += logText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Gestures"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                child: Text(
                  'Hola Sandraaaaaaaaaaaaaaaa aqui puede ir una imagen',
                ),
                //onTap: () => _escribirLog('tap'), //detecta el click
                //onTapDown: (details) => _escribirLog('onTapDown: ${details.globalPosition} \n ${details.localPosition} \n ${details.kind}'), //juego cirujano coordenadas
                // onTapUp: (details) => _escribirLog('onTapUp: $details'),
                 //onTapCancel: () => _escribirLog('onTapCancel'), //cliclo y arrastro y sabe que msalgo de la imagen
                // onDoubleTap: () => _escribirLog('onDoubleTap'), //doble click y salta
                // onLongPress: () => _escribirLog('onLongPress'),
               // onVerticalDragDown: (details) => _escribirLog('onVerticalDragDown: ${details}'),
                // onVerticalDragStart: (details) => _escribirLog('onVerticalDragStart: ${details}'),
                //onVerticalDragUpdate: (details) => _escribirLog('onVerticalDragUpdate: $details'),
                // onVerticalDragEnd: (details) =>_escribirLog('onVerticalDragEnd: ${details.velocity}'),
                //onVerticalDragCancel: () => _escribirLog('onVerticalDragCancel'),
                //onHorizontalDragDown: (details) =>_escribirLog('onHorizontalDragDown: ${details}'),
                //onHorizontalDragStart: (details) =>_escribirLog('onHorizontalDragStart: ${details}'),
                //onHorizontalDragUpdate: (details) =>_escribirLog('onHorizontalDragUpdate: ${details}'),
                //onHorizontalDragEnd: (details) =>_escribirLog('onHorizontalDragEnd: ${details}'),
                //onHorizontalDragCancel: () =>_escribirLog('onHorizontalDragCancel')
              ),
              Center(
                  child: TextField(
                    maxLines: 20,
                    controller: TextEditingController(
                      text: '$_log',
                    ),
                    readOnly: true,
                  )),
              TextButton(child: Text('RESETEAR'), onPressed: () => _clearLog())
            ],
          ),
        ));
  }
}
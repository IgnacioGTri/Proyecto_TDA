import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../BaseDeDatos/DatabaseHelper.dart';

class SimonDiceGame extends StatefulWidget {
  const SimonDiceGame({Key? key}) : super(key: key);

  @override
  State<SimonDiceGame> createState() => _SimonDiceGameState();
}

class _SimonDiceGameState extends State<SimonDiceGame> {
  // Estado del juego
  bool _jugando = false;
  bool _esTurnoDelSistema = false;
  int _ronda = 0; // Puntuación actual (rondas superadas)
  late DateTime _horaInicioPartida;

  // Secuencias
  List<int> _secuenciaObjetivo = [];
  List<int> _secuenciaUsuario = [];

  // Control visual
  int _botonIluminado = -1; // -1 significa ninguno
  final Random _random = Random();

  // Los 4 colores neón del panel
  final List<Color> _colores = [
    Colors.redAccent,    // 0: Arriba Izquierda
    Colors.greenAccent,  // 1: Arriba Derecha
    Colors.blueAccent,   // 2: Abajo Izquierda
    Colors.amberAccent,  // 3: Abajo Derecha
  ];

  // ================= LÓGICA DEL JUEGO =================

  void _start() {
    setState(() {
      _jugando = true;
      _ronda = 0;
      _secuenciaObjetivo.clear();
      _secuenciaUsuario.clear();
      _horaInicioPartida = DateTime.now();
    });

    // Pequeña pausa antes de empezar
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _siguienteRonda();
    });
  }

  void _reset() {
    setState(() {
      _jugando = false;
      _esTurnoDelSistema = false;
      _ronda = 0;
      _secuenciaObjetivo.clear();
      _secuenciaUsuario.clear();
      _botonIluminado = -1;
    });
  }

  void _finJuego() async {
    setState(() {
      _jugando = false;
      _esTurnoDelSistema = false;
      _botonIluminado = -1;
    });

    // Guardamos en la Base de Datos (La puntuación es la ronda a la que llegaste)
    final segundosJugados = DateTime.now().difference(_horaInicioPartida).inSeconds;
    await DatabaseHelper().insertRecord('Simon Dice', _ronda, segundosJugados);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('💥 ¡ERROR!', textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ronda $_ronda', style: const TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text('Memoria máxima alcanzada', style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: const StadiumBorder()),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _siguienteRonda() async {
    if (!_jugando) return;

    setState(() {
      _esTurnoDelSistema = true;
      _secuenciaUsuario.clear();
      // Añadimos un nuevo color aleatorio a la secuencia
      _secuenciaObjetivo.add(_random.nextInt(4));
    });

    // Pequeña pausa para separar las rondas
    await Future.delayed(const Duration(milliseconds: 800));

    // Reproducir secuencia
    for (int i = 0; i < _secuenciaObjetivo.length; i++) {
      if (!mounted || !_jugando) return;

      // Iluminar botón
      setState(() => _botonIluminado = _secuenciaObjetivo[i]);

      // El tiempo de luz se hace un pelín más rápido en rondas altas
      int tiempoLuz = max(200, 500 - (_ronda * 15));
      await Future.delayed(Duration(milliseconds: tiempoLuz));

      if (!mounted || !_jugando) return;

      // Apagar botón
      setState(() => _botonIluminado = -1);

      // Tiempo oscuro entre luces
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (!mounted || !_jugando) return;

    // Termina el sistema, le toca al jugador
    setState(() {
      _esTurnoDelSistema = false;
    });
  }

  void _onBotonPulsado(int index) async {
    // Si no estás jugando o le toca al sistema, ignoramos tus toques
    if (!_jugando || _esTurnoDelSistema) return;

    // Iluminar el botón brevemente como feedback táctil
    setState(() => _botonIluminado = index);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _botonIluminado = -1);
    });

    _secuenciaUsuario.add(index);
    int posicionActual = _secuenciaUsuario.length - 1;

    // Comprobar si has fallado
    if (_secuenciaUsuario[posicionActual] != _secuenciaObjetivo[posicionActual]) {
      _finJuego();
      return;
    }

    // Comprobar si has completado la secuencia entera correctamente
    if (_secuenciaUsuario.length == _secuenciaObjetivo.length) {
      setState(() {
        _esTurnoDelSistema = true; // Bloqueamos para que no pulses de más
        _ronda++;
      });
      // Empezar siguiente ronda
      _siguienteRonda();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Fondo azul muy oscuro
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _customAppBar(),
              _scoreBoard(),

              const Spacer(),

              // Mensaje de estado (TURNO)
              AnimatedOpacity(
                opacity: _jugando ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _esTurnoDelSistema ? 'MIRA Y APRENDE...' : '¡TU TURNO!',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _esTurnoDelSistema ? Colors.white54 : Colors.amberAccent,
                      letterSpacing: 2
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ================= PANEL NEÓN (2x2) =================
              SizedBox(
                width: 320,
                height: 320,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _botonSimon(0)),
                          const SizedBox(width: 15),
                          Expanded(child: _botonSimon(1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _botonSimon(2)),
                          const SizedBox(width: 15),
                          Expanded(child: _botonSimon(3)),
                        ],
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
        const Text('SIMON DICE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
        const SizedBox(width: 40),
      ],
    ),
  );

  Widget _scoreBoard() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
        child: Column(
          children: [
            const Text('RONDA ACTUAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white54)),
            const SizedBox(height: 5),
            Text('$_ronda', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)),
          ],
        ),
      ),
    ],
  );

  Widget _bottomButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _jugando ? null : _start,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
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

  // Widget clave: El botón que brilla
  Widget _botonSimon(int index) {
    bool estaEncendido = _botonIluminado == index;
    Color colorBase = _colores[index];

    return GestureDetector(
      onTapDown: (_) => _onBotonPulsado(index), // Usamos onTapDown para respuesta inmediata
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: estaEncendido ? colorBase : colorBase.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30), // Bordes muy redondeados
          border: Border.all(
            color: estaEncendido ? Colors.white : colorBase.withOpacity(0.3),
            width: estaEncendido ? 3 : 2,
          ),
          boxShadow: [
            if (estaEncendido)
              BoxShadow(color: colorBase.withOpacity(0.8), blurRadius: 30, spreadRadius: 5)
          ],
        ),
      ),
    );
  }
}
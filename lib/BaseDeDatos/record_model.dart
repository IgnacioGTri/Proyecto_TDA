class Record {
  final int? id;
  final String nombreJuego;
  final int puntuacion;
  final int segundosJugados;
  final String fecha;

  Record({
    this.id,
    required this.nombreJuego,
    required this.puntuacion,
    required this.segundosJugados,
    required this.fecha
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombreJuego': nombreJuego,
      'puntuacion': puntuacion,
      'segundosJugados': segundosJugados,
      'fecha': fecha,
    };
  }
}
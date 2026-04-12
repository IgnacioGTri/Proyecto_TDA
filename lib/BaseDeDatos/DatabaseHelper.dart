import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'records_juegos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE records(id INTEGER PRIMARY KEY AUTOINCREMENT, nombreJuego TEXT, puntuacion INTEGER, segundosJugados INTEGER, fecha TEXT)',
        );
      },
    );
  }
  Future<int> obtenerTiempoTotal() async {
    final db = await database;
    var resultado = await db.rawQuery('SELECT SUM(segundosJugados) as total FROM records');

    // Si no hay datos, devolvemos 0
    return resultado.first['total'] as int? ?? 0;
  }
  Future<List<Map<String, dynamic>>> getRecords() async {
    final db = await database;
    // Esto devuelve todos los records ordenados por puntuación (del más alto al más bajo)
    return await db.query('records', orderBy: 'puntuacion DESC');
  }

  Future<void> insertRecord(String juego, int puntos, int segundos) async {
    final db = await database;

    // 1. Buscamos si ya existe un registro para este juego
    List<Map<String, dynamic>> existente = await db.query(
      'records',
      where: 'nombreJuego = ?',
      whereArgs: [juego],
    );

    if (existente.isEmpty) {
      // 2. Si no existe, lo creamos por primera vez
      await db.insert('records', {
        'nombreJuego': juego,
        'puntuacion': puntos,
        'segundosJugados': segundos,
        'fecha': DateTime.now().toString(),
      });
      print("Primer record guardado para $juego");
    } else {
      // 3. Si existe, comparamos la puntuación
      int recordActual = existente.first['puntuacion'];

      if (puntos > recordActual) {
        // Solo actualizamos si la nueva puntuación es mejor
        await db.update(
          'records',
          {
            'puntuacion': puntos,
            'segundosJugados': segundos,
            'fecha': DateTime.now().toString(),
          },
          where: 'nombreJuego = ?',
          whereArgs: [juego],
        );
        print("¡Nuevo récord personal en $juego!");
      } else {
        print("No superaste el récord anterior de $recordActual");
      }
    }
  }
}
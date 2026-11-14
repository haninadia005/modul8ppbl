import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/pembacaan_sensor.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance =
      DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'peringatan_dini.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pembacaan_sensor (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jenis_sensor TEXT NOT NULL,
            nilai REAL NOT NULL,
            satuan TEXT NOT NULL,
            status TEXT NOT NULL,
            lokasi TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            waktu TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE: Menambahkan pembacaan sensor
  Future<int> tambahPembacaan(
      PembacaanSensor sensor) async {
    final db = await database;

    return db.insert(
      'pembacaan_sensor',
      sensor.toMap(),
    );
  }

  // READ: Mengambil seluruh pembacaan
  Future<List<PembacaanSensor>> ambilSemuaPembacaan() async {
    final db = await database;

    final hasil = await db.query(
      'pembacaan_sensor',
      orderBy: 'waktu DESC, id DESC',
    );

    return hasil
        .map((data) => PembacaanSensor.fromMap(data))
        .toList();
  }

  // UPDATE: Mengubah data berdasarkan ID
  Future<int> ubahPembacaan(
      PembacaanSensor sensor) async {
    final db = await database;

    return db.update(
      'pembacaan_sensor',
      sensor.toMap(),
      where: 'id = ?',
      whereArgs: [sensor.id],
    );
  }

  // DELETE: Menghapus data berdasarkan ID
  Future<int> hapusPembacaan(int id) async {
    final db = await database;

    return db.delete(
      'pembacaan_sensor',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

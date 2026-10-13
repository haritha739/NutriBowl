import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Local SQLite database used to persist NutriBowl website state on-device.
/// The embedded website sends cart, order, profile, fitness and reward data
/// through the WebView JavaScript bridge.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final base = await getDatabasesPath();
    _database = await openDatabase(
      p.join(base, 'nutribowl.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE app_data (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE database_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT NOT NULL,
            action TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<void> save(String key, String value) async {
    final db = await database;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.insert(
      'app_data',
      {'key': key, 'value': value, 'updated_at': now},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.insert('database_events', {
      'key': key,
      'action': 'save',
      'created_at': now,
    });
  }

  Future<void> delete(String key) async {
    final db = await database;
    final now = DateTime.now().toUtc().toIso8601String();
    await db.delete('app_data', where: 'key = ?', whereArgs: [key]);
    await db.insert('database_events', {
      'key': key,
      'action': 'delete',
      'created_at': now,
    });
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete('app_data');
  }

  Future<Map<String, String>> readAll() async {
    final db = await database;
    final rows = await db.query('app_data');
    return {for (final row in rows) row['key'] as String: row['value'] as String};
  }

  Future<List<Map<String, Object?>>> recentEvents({int limit = 20}) async {
    final db = await database;
    return db.query('database_events', orderBy: 'id DESC', limit: limit);
  }
}

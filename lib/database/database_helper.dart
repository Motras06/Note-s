import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _databaseName = 'notes.db';
  static const int _databaseVersion = 1;

  static const String notesTable = 'notes';

  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnContent = 'content';
  static const String columnCategory = 'category';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  static const String columnIsPinned = 'is_pinned';
  static const String columnIsArchived = 'is_archived';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _databaseName);

    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $notesTable (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnContent TEXT NOT NULL DEFAULT '',
        $columnCategory TEXT,
        $columnCreatedAt INTEGER NOT NULL,
        $columnUpdatedAt INTEGER NOT NULL,
        $columnIsPinned INTEGER NOT NULL DEFAULT 0,
        $columnIsArchived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_notes_updated_at
      ON $notesTable ($columnUpdatedAt)
    ''');

    await db.execute('''
      CREATE INDEX idx_notes_category
      ON $notesTable ($columnCategory)
    ''');
  }

  Future<int> insertNote(Map<String, dynamic> note) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final data = Map<String, dynamic>.from(note);

    data.remove(columnId);
    data.putIfAbsent(columnCreatedAt, () => now);
    data[columnUpdatedAt] = now;

    return db.insert(notesTable, data);
  }

  Future<List<Map<String, dynamic>>> getAllNotes({
    bool includeArchived = false,
  }) async {
    final db = await database;

    return db.query(
      notesTable,
      where: includeArchived ? null : '$columnIsArchived = ?',
      whereArgs: includeArchived ? null : [0],
      orderBy: '$columnIsPinned DESC, $columnUpdatedAt DESC',
    );
  }

  Future<Map<String, dynamic>?> getNoteById(int id) async {
    final db = await database;

    final result = await db.query(
      notesTable,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<List<Map<String, dynamic>>> searchNotes(
    String query, {
    bool includeArchived = false,
  }) async {
    final db = await database;
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      return getAllNotes(includeArchived: includeArchived);
    }

    final archiveCondition = includeArchived ? '' : 'AND $columnIsArchived = 0';

    return db.rawQuery(
      '''
      SELECT *
      FROM $notesTable
      WHERE (
        $columnTitle LIKE ? OR
        $columnContent LIKE ? OR
        $columnCategory LIKE ?
      )
      $archiveCondition
      ORDER BY $columnIsPinned DESC, $columnUpdatedAt DESC
      ''',
      ['%$trimmedQuery%', '%$trimmedQuery%', '%$trimmedQuery%'],
    );
  }

  Future<int> updateNote(int id, Map<String, dynamic> note) async {
    final db = await database;

    final data = Map<String, dynamic>.from(note);

    data.remove(columnId);
    data.remove(columnCreatedAt);
    data[columnUpdatedAt] = DateTime.now().millisecondsSinceEpoch;

    return db.update(notesTable, data, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> setPinned(int id, bool isPinned) async {
    final db = await database;

    return db.update(
      notesTable,
      {
        columnIsPinned: isPinned ? 1 : 0,
        columnUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> setArchived(int id, bool isArchived) async {
    final db = await database;

    return db.update(
      notesTable,
      {
        columnIsArchived: isArchived ? 1 : 0,
        columnUpdatedAt: DateTime.now().millisecondsSinceEpoch,
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getNotesByStatus({
    required bool isArchived,
  }) async {
    final db = await database;
    return db.query(
      notesTable,
      where: '$columnIsArchived = ?',
      whereArgs: [isArchived ? 1 : 0],
      orderBy: '$columnIsPinned DESC,$columnUpdatedAt DESC',
    );
  }

  Future<List<String>> getUniqueCategories() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT DISTINCT $columnCategory
      FROM $notesTable
      WHERE $columnCategory IS NOT NULL AND trim($columnCategory) != ''
      ORDER BY $columnCategory
    ''');
    return result.map((row) => row[columnCategory] as String).toList();
  }

  Future<int> deleteNote(int id) async {
    final db = await database;

    return db.delete(notesTable, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

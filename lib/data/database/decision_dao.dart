import 'package:photo_swipe/data/database/app_database.dart';
import 'package:photo_swipe/models/photo_decision.dart';
import 'package:photo_swipe/models/photo_status.dart';
import 'package:sqflite/sqflite.dart';

/// Reads and writes the keep / trash decisions.
class DecisionDao {
  DecisionDao(this._database);

  final AppDatabase _database;

  static const _table = AppDatabase.decisionsTable;

  /// All decisions, most recent first.
  Future<List<PhotoDecision>> getAll() async {
    final db = await _database.database;
    final rows = await db.query(_table, orderBy: 'decided_at DESC');
    return [
      for (final row in rows)
        PhotoDecision(
          photoId: row['photo_id']! as String,
          status: PhotoStatus.fromDb(row['status']! as String),
          decidedAt: DateTime.fromMillisecondsSinceEpoch(
            row['decided_at']! as int,
          ),
        ),
    ];
  }

  /// Saves a decision, replacing any earlier one for the same photo.
  Future<void> upsert(String photoId, PhotoStatus status) async {
    final db = await _database.database;
    await db.insert(
      _table,
      {
        'photo_id': photoId,
        'status': status.dbValue,
        'decided_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Forgets the decisions for these photos (used after they are deleted).
  Future<void> removeMany(Iterable<String> photoIds) async {
    if (photoIds.isEmpty) return;
    final db = await _database.database;
    final batch = db.batch();
    for (final id in photoIds) {
      batch.delete(_table, where: 'photo_id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }
}

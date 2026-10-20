import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Opens the local database and creates its tables.
/// Only this file knows the table layout; the rest of the app goes through
/// DAO classes such as DecisionDao.
class AppDatabase {
  static const _fileName = 'photo_swipe.db';

  /// Bump this and add a step in [_open] when the tables change later.
  static const _version = 1;

  static const decisionsTable = 'decisions';

  /// Opened once, on first use.
  late final Future<Database> database = _open();

  Future<Database> _open() async {
    final folder = await getDatabasesPath();
    return openDatabase(
      p.join(folder, _fileName),
      version: _version,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE $decisionsTable (
  photo_id TEXT PRIMARY KEY NOT NULL,
  status TEXT NOT NULL,
  decided_at INTEGER NOT NULL
)''');
      },
    );
  }
}

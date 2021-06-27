import 'package:sqflite/sqflite.dart';

import 'package:traindown/traindown.dart';

import 'session.dart';

class Repo {
  final String path;
  final String filename;

  Database _database;
  bool started = false;

  Repo(this.path, {this.filename = 'transponder.db'});

  static const String migrationsTableName = "migrations";
  static const String sessionsTableName = "sessions";

  String createSessions = """
    create table $sessionsTableName (
      id integer primary key,
      occurred_at datetime not null default now,

      traindown text not null default '',

      created_at datetime not null default now,
      updated_at datetime
    );
  """;

  String createMetadata = """
    create table metadata (
      key text not null,
      value text not null,
      created_at datetime not null default now,
      primary key(key, value)
    );
  """;

  String createSessionMetadata = """
    create table session_metadata (
      session_id int not null,
      key text not null,
      value text not null,
      created_at datetime not null default now,
      primary key(session_id, key, value),
      foreign key(session_id) references sessions(session_id),
      foreign key(key, value) references metadata(key, value)
    );
  """;

  String createMovements = """
    create table movements (
      name text unique not null,
      created_at datetime not null default now,
      primary key(name)
    );
  """;

  String createSessionMovement = """
    create table session_movement (
      session_id int not null,
      movement text not null,
      created_at datetime not null default now,
      primary key(session_id, movement),
      foreign key(session_id) references sessions(session_id),
      foreign key(movement) references movements(movement)
    );
  """;

  String createMigrations = """
    create table if not exists $migrationsTableName (
      key text not null,
      created_at datetime not null default now,
      primary key(key)
    );
  """;

  Future<void> start() async {
    // TODO: REMOVE!!!
    await deleteDatabase("$path/$filename");

    print("$path/$filename");

    _database = await openDatabase("$path/$filename", version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(createMigrations);
      started = true;
    });

    await migrate(createSessions, 'create sessions table');
    await migrate(createMetadata, 'create metadata table');
    await migrate(createSessionMetadata, 'create session metadata table');
  }

  Database get database => _database;

  Future<List<StoredSession>> allSessions() async {
    List<Map> results =
        await _database.query(sessionsTableName, columns: ['id', 'traindown']);

    return results
        .map((r) => StoredSession.fromRepo(
            id: r['id'], repo: this, traindown: r['traindown']))
        .toList();
  }

  Future<bool> create(StoredSession session) async {
    if (!started) return false;

    Session rawSession = session.session;

    Formatter formatter = Formatter();
    session.traindown = formatter.format(rawSession.tokens);
    String createdAt = DateTime.now().toString();

    int maybeId = await _database.insert(sessionsTableName, {
      'occurred_at': rawSession.occurred.toString(),
      'traindown': session.traindown,
      'created_at': DateTime.now().toString()
    });

    if (maybeId <= 0) {
      return false;
    } else {
      session.id = maybeId;
      return true;
    }
  }

  Future<bool> canMigrate(String migration) async {
    if (!started) return false;

    List<Map> maps = await _database.query(migrationsTableName,
        columns: ['key'], where: 'key = ?', whereArgs: [migration]);

    return maps.isEmpty;
  }

  Future<bool> markMigration(String migration) async {
    if (!started) return false;

    int maybeId = await _database.insert(migrationsTableName,
        {'key': migration, 'created_at': DateTime.now().toString()});

    return maybeId > 0;
  }

  Future<void> migrate(String migrationStr, String name) async {
    print("Migrating $name...");

    canMigrate(name).then((canMigrate) async {
      print("canMigrate: $canMigrate");
      if (!canMigrate) {
        print("Migration already ran! Skipping.");
      } else {
        await _database.execute(migrationStr);
        await markMigration(name);
        print("Done.");
      }
    });
  }

  Future<bool> update(StoredSession session) async {
    if (!started) return false;

    Session rawSession = session.session;

    Formatter formatter = Formatter();
    session.traindown = formatter.format(rawSession.tokens);
    String createdAt = DateTime.now().toString();

    int maybeId = await _database.update(
        sessionsTableName,
        {
          'occurred_at': rawSession.occurred.toString(),
          'traindown': session.traindown,
          'updated_at': DateTime.now().toString()
        },
        where: 'id = ?',
        whereArgs: [session.id]);

    return maybeId > 0;
  }

  // NOTE: This is to bootstrap the db.
  Future<bool> upsertFileSession(TTSession session) async {
    if (!started) return false;

    Session rawSession = session.session;

    String occurred = rawSession.occurred.toString();
    Formatter formatter = Formatter();
    String traindown = formatter.format(rawSession.tokens);
    String createdAt = DateTime.now().toString();

    String query = """
      insert into $sessionsTableName(occurred_at, traindown, created_at)
      values('$occurred', '$traindown', '$createdAt');
    """;

    int maybeId = await _database.rawInsert(query);

    return maybeId > 0;
  }
}

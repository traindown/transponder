import 'package:sqflite/sqflite.dart';

import 'package:traindown/traindown.dart';

import 'stored_session.dart';

class Repo {
  final bool debug;
  final String path;
  final String filename;

  Database? _database;
  bool started = false;

  Repo(this.path, {this.debug = false, this.filename = 'transponder.db'});

  static const String logsTableName = "logs";
  static const String migrationsTableName = "migrations";
  static const String sessionsTableName = "sessions";

  String createLogs = """
    create table if not exists $logsTableName (
      type text not null default 'info',
      subject text not null,
      message text not null,
      created_at datetime not null default(strftime('%Y-%m-%d %H:%M:%f', 'now'))
    );
    create index log_type on $logsTableName(type);
    create index log_created_at on $logsTableName(created_at);
  """;

  String createMigrations = """
    create table if not exists $migrationsTableName (
      key text not null,
      created_at datetime not null default(strftime('%Y-%m-%d %H:%M:%f', 'now')),
      primary key(key)
    );
  """;

  String createSessions = """
    create table $sessionsTableName (
      id integer primary key,
      occurred_at datetime not null default current_timestamp,

      traindown text not null default '',

      created_at datetime not null default(strftime('%Y-%m-%d %H:%M:%f', 'now')),
      updated_at datetime
    );
  """;

  String addSoftDeleteToSessions = """
    alter table $sessionsTableName
    add column deleted_at datetime;
  """;

  Future<void> start() async {
    _database = await openDatabase("$path/$filename");

    print("Database at: ${_database!.path}");

    await _database!.execute(createLogs);
    log("Created database at $path/$filename", subject: "Repo");
    log("Created logs table", subject: "Repo");

    await _database!.execute(createMigrations);
    log("Created migrations table", subject: "Repo");

    started = true;

    await migrate(createSessions, 'create sessions table');
    await migrate(addSoftDeleteToSessions, 'add sessions deleted_at');
  }

  Database? get database => _database;
  String get databasePath => _database!.path;

  Future<List<StoredSession>> allSessions() async {
    List<Map> results = await _database!.query(sessionsTableName,
        columns: ['id', 'traindown'], where: 'deleted_at is null');

    return results
        .map((r) => StoredSession.fromRepo(
            id: r['id'], repo: this, traindown: r['traindown']))
        .toList();
  }

  Future<bool> create(StoredSession session) async {
    if (!started) await start();

    Session rawSession = session.session!;

    Formatter formatter = Formatter();
    session.traindown = formatter.format(rawSession.tokens);

    int maybeId = await _database!.insert(sessionsTableName, {
      'occurred_at': rawSession.occurred.toString(),
      'traindown': session.traindown,
      'created_at': DateTime.now().toString()
    });

    if (maybeId <= 0) return false;

    session.id = maybeId;
    return true;
  }

  Future<bool> canMigrate(String migration) async {
    if (!started) await start();

    List<Map> maps = await _database!.query(migrationsTableName,
        columns: ['key'], where: 'key = ?', whereArgs: [migration]);

    return maps.isEmpty;
  }

  Future<bool> destroy(StoredSession session) async {
    if (!started) await start();

    log("Deleting ${session.id}", subject: 'Session');

    int maybeId = await _database!.update(
        sessionsTableName,
        {
          'deleted_at': DateTime.now().toString(),
          'updated_at': DateTime.now().toString()
        },
        where: 'id = ?',
        whereArgs: [session.id]);

    log("Deleted ${session.id}: ${maybeId > 0}", subject: 'Session');

    return maybeId > 0;
  }

  Future<List<Map>> dumpLogs({int limit = 50}) async {
    if (!started) await start();

    return _database!
        .query(logsTableName, orderBy: 'created_at desc', limit: limit);
  }

  Future<bool> log(String message,
      {String subject = 'Application', String type = 'info'}) async {
    if (!started) return false;

    if (debug) print("[$type] $subject: $message");

    int maybeId = await _database!.insert(
        logsTableName, {'type': type, 'subject': subject, 'message': message});

    return maybeId > 0;
  }

  Future<bool> markMigration(String migration) async {
    if (!started) await start();

    int maybeId = await _database!.insert(migrationsTableName,
        {'key': migration, 'created_at': DateTime.now().toString()});

    return maybeId > 0;
  }

  Future<void> migrate(String migrationStr, String name) async {
    if (!started) await start();

    bool proceed = await canMigrate(name);

    if (proceed) {
      log("Migrating '$name'", subject: 'Repo');
      await _database!.execute(migrationStr);
      await markMigration(name);
      log("Migrated '$name'", subject: 'Repo');
    }
  }

  // NOTE: This is temporary. We need to clean up any garbage that may have
  // been left during the transition to db backed persistence.
  Future<void> tidy() async {
    String primaryIds = 'select min(id) from sessions group by occurred_at;';
    var res = await _database!.rawQuery(primaryIds);
    var idsToKeep = res.map((resMap) => resMap.values.first);

    for (StoredSession session in await allSessions()) {
      if (idsToKeep.contains(session.id)) continue;

      log("Tidying ${session.id} for ${session.occurred}", subject: 'Session');
      await session.destroy();
    }
  }

  Future<bool> update(StoredSession session) async {
    if (!started) await start();

    log("Updating ${session.id}", subject: 'Session');

    Session rawSession = session.session!;

    Formatter formatter = Formatter();
    session.traindown = formatter.format(rawSession.tokens);

    int maybeId = await _database!.update(
        sessionsTableName,
        {
          'occurred_at': rawSession.occurred.toString(),
          'traindown': session.traindown,
          'updated_at': DateTime.now().toString()
        },
        where: 'id = ?',
        whereArgs: [session.id]);

    log("Updated ${session.id}: ${maybeId > 0}", subject: 'Session');

    return maybeId > 0;
  }

  // NOTE: This is to bootstrap the db.
  Future<bool> upsertFileSession(String content) async {
    if (!started) await start();

    log('Upserting legacy file: $content', subject: 'File');

    Parser parser = Parser(content);
    Session session;

    try {
      // TODO: Error handling
      session = Session(parser.tokens());
    } catch (e) {
      log('Failed to upsert: $e', subject: 'File', type: 'error');
      return false;
    }

    Formatter formatter = Formatter();
    String traindown = formatter.format(session.tokens);

    int maybeId = await _database!.insert(sessionsTableName, {
      'occurred_at': session.occurred.toString(),
      'traindown': traindown,
      'created_at': DateTime.now().toString()
    });

    log("Upserted: ${maybeId > 0}", subject: "File");

    return maybeId > 0;
  }
}

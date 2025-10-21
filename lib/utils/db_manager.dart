import 'dart:convert';

import 'package:jande/models/audio_page.dart';
import 'package:jande/models/historique.dart';
import 'package:jande/models/exam_questions.dart';
import 'package:jande/models/exams.dart';
import 'package:jande/models/language.dart';
import 'package:jande/models/modules.dart';
import 'package:jande/models/themes.dart';
import 'package:jande/models/users.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'dart:async';

class DbManager {
  static String dbName = "jande.db";
  static int dbVersion = 1;

  static Future<Database> db() async {
    var databasesPath = await getDatabasesPath();
    return openDatabase(
      join(databasesPath, dbName),
      version: dbVersion,
      onCreate: (Database database, int version) async {
        /*print("********onCreate VERSION");
        print(version);*/
        await createTables(database);
      },
      onUpgrade: (Database database, int oldVersion, int newVersion) async {

      },
    );
  }


  static createTables(Database database) async {
    try {
      var table_user = "CREATE TABLE IF NOT EXISTS users"
          "(id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "online_id INTEGER,"
          "role_id INTEGER,"
          "role_name TEXT,"
          "first_name TEXT,"
          "last_name TEXT,"
          "contact TEXT,"
          "email TEXT,"
          "is_active TEXT,"
          "slug TEXT)";

      var table_language = "CREATE TABLE IF NOT EXISTS languages"
          "(id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "online_id INTEGER,"
          "code TEXT,"
          "name TEXT,"
          "is_active INTEGER)";

      var table_theme = "CREATE TABLE IF NOT EXISTS themes"
          "(id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "online_id INTEGER,"
          "nbr_modules INTEGER,"
          "title TEXT,"
          "icon_name TEXT,"
          "audio_intro_url TEXT,"
          "created_at TEXT,"
          "updated_at TEXT)";

     var table_module = "CREATE TABLE IF NOT EXISTS modules"
         "(id INTEGER PRIMARY KEY AUTOINCREMENT,"
         "online_id INTEGER,"
         "theme_id INTEGER,"
         "duration_min INTEGER DEFAULT 0,"
         "language_id INTEGER,"
         "theme_name TEXT,"
         "title TEXT,"
         "text_content TEXT,"
         "audio_content_url TEXT,"
         "thumbnail_url TEXT,"
         "language_code TEXT,"
         "language_name TEXT,"
         "is_completed TEXT)";

     var table_exam = "CREATE TABLE IF NOT EXISTS exams"
         "(id INTEGER PRIMARY KEY AUTOINCREMENT,"
         "online_id INTEGER,"
         "theme_id INTEGER,"
         "passing_score INTEGER,"
         "theme_name TEXT,"
         "description TEXT,"
         "title TEXT,"
         "audio_instructions_url TEXT)";

     var table_question = "CREATE TABLE IF NOT EXISTS questions"
         "(id INTEGER PRIMARY KEY AUTOINCREMENT,"
         "online_id INTEGER,"
         "exam_id INTEGER,"
         "theme_id INTEGER,"
         "theme_name TEXT,"
         "question_text TEXT,"
         "audio_question_url TEXT,"
         //"order TEXT,"
         "audios TEXT,"
         "answers TEXT,"
         "is_multiple_choice TEXT)";

     var table_answer = "CREATE TABLE IF NOT EXISTS examanswers"
         "(id INTEGER PRIMARY KEY AUTOINCREMENT,"
         "question_id INTEGER,"
         "answer_text TEXT,"
         "audio_answer_url TEXT,"
         "is_correct TEXT)";

     var table_result = "CREATE TABLE IF NOT EXISTS examresults"
         "(id INTEGER PRIMARY KEY AUTOINCREMENT,"
         "theme_id INTEGER,"
         "user_id INTEGER,"
         "nbr_question TEXT,"
         "score TEXT,"
         "theme_name TEXT,"
         "created_at TEXT,"
         "time TEXT)";

     var table_audio_page = "CREATE TABLE IF NOT EXISTS introductions"
         "(id INTEGER PRIMARY KEY AUTOINCREMENT,"
         "online_id INTEGER,"
         "language_id INTEGER,"
         "language_name TEXT NULL,"
         "titre TEXT,"
         "code_titre TEXT,"
         "path_audio TEXT,"
         "path_image TEXT,"
         "duration_min INTEGER)";


      await database.execute(table_user);
      await database.execute(table_language);
      await database.execute(table_theme);
      await database.execute(table_module);
      await database.execute(table_exam);
      await database.execute(table_question);
      await database.execute(table_answer);
      await database.execute(table_result);
      await database.execute(table_audio_page);


    } catch (e) {
      print("******* Erreur création tables");
      print(e);
    }
  }


  /*------------ User-----------------*/

  Future<int?> insertDbUser(User item) async {
    int? resultat;
    final db = await DbManager.db();
    final data = {
      'id': item.id,
      'online_id': item.online_id,
      'role_id': item.role_id,
      'role_name': "user",
      'first_name': item.first_name,
      'last_name': item.last_name,
      'contact': item.contact,
      'email': item.email,
      'is_active': item.is_active,
      'slug': item.slug,
    };
    resultat = await db.insert(
      'users',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return resultat;
  }

  Future<List<User>> getAllDbUser() async {
    final db = await DbManager.db();
    List<Map<String, Object?>>? liste = await db.query('users');
    List<User> items = liste.map((element) => User.fromJson(element)).toList();
    return items;
  }

  Future<User?> getDbUser(String item_slug) async {
    final db = await DbManager.db();
    List<Map<String, dynamic>> liste = await db.query('users',
        where: "slug = ?", whereArgs: [item_slug], limit: 1);
    List<User> items = liste.map((element) => User.fromJson(element)).toList();
    return items.first;
  }

  Future<User> getUser() async {
    int id=1;
    final db = await DbManager.db();
    List<Map<String, dynamic>> liste = await db.query('users', limit: 1);
    // await db.query('users', where: "onlineid = ?", whereArgs: [id], limit: 1);
    // List<User> items = liste.map((element) => User.fromJson(element)).toList();

    if (liste.isNotEmpty) {
      List<User> items = liste.map((element) => User.fromJson(element)).toList();
      return items.first;
    } else {
      throw Exception('Aucun utilisateur trouvé');  // Ou tu peux renvoyer une valeur par défaut si nécessaire
    }
  }

  Future<int?> updateDbUser(User item) async {
    int? resultat;
    final db = await DbManager.db();
    final data = {
      // 'id': item.id,
      'online_id': item.online_id,
      'role_id': item.role_id,
      'role_name': item.role_name,
      'first_name': item.first_name,
      'last_name': item.last_name,
      'contact': item.contact,
      'email': item.email,
      'is_active': item.is_active,
      'slug': item.slug,
    };

    resultat = await db.update('users', data, where: "slug = ?", whereArgs: [item.slug]);
    return resultat;
  }

  Future<int?> countDbUser() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('SELECT COUNT(*) FROM users');
    int? compte = Sqflite.firstIntValue(comptage!);
    return compte;
  }

  Future<void> updatePassword(String email, String newPassword) async {
    final db = await DbManager.db();
    await db.update('users', {'password': newPassword},where: 'email = ?',whereArgs: [email],);
  }

  Future<void> removeDbUser(String item_slug) async {
    final db = await DbManager.db();
    await db.delete("users", where: "slug = ?", whereArgs: [item_slug]);
  }

  Future<void> removeAllDbUser() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('DELETE FROM users');
  }


/*------------ language-----------------*/

  Future<int?> insertDbLanguage(Language language) async {
    int? resultatlanguage;
    final db = await DbManager.db();
    final data = {
      "online_id": language.online_id,
      "code": language.code,
      "name": language.name,
      "is_active": language.is_active
    };
    resultatlanguage = await db.insert(
        'languages',
        data
    );
    return resultatlanguage;
  }

  Future<List<Language>> getAllDbLanguage() async {
    final db = await DbManager.db();
    List<Map<String, dynamic>> element = await db.query('languages');
    List<Language> langauges = element.map((data) => Language.fromJson(data)).toList();
    return langauges;
  }

  Future<void> removeAllDbLanguage() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('DELETE FROM languages');
  }

  Future<int?> countDbLanguage() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('SELECT COUNT(*) FROM languages');
    int? compte = Sqflite.firstIntValue(comptage!);
    return compte;
  }
  Future<Language> getDbLanguage(language_id) async {
    final db = await DbManager.db();
    final List<Map<String, dynamic>> themeData = await db.query('languages',
        where: "online_id = ?", whereArgs: [language_id], limit: 1);

    List<Language> liste = themeData.map((data) => Language.fromJson(data)).toList();

    return liste.first;
  }
/*------------ Thème-----------------*/

  Future<int?> insertDbTheme(Themes theme) async {
    int? resultatthemes;
    final db = await DbManager.db();
    final data = {
      "online_id": theme.online_id,
      "nbr_modules": theme.nbr_modules,
      "title": theme.title,
      "icon_name": theme.icon_name,
      "audio_intro_url": theme.audio_intro_url,
    };
    resultatthemes = await db.insert(
        'themes',
        data
    );
    return resultatthemes;
  }

  Future<List<Themes>> getAllDbthemes() async {
    final db = await DbManager.db();
    List<Map<String, dynamic>> element = await db.query('themes');
    List<Themes> theme = element.map((data) => Themes.fromJson(data)).toList();
    return theme;
  }

  Future<void> removeAllDbthemes() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('DELETE FROM themes');
  }

  Future<int?> countDbthemes() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('SELECT COUNT(*) FROM themes');
    int? compte = Sqflite.firstIntValue(comptage!);
    return compte;
  }
  Future<Themes> getDbthemes(themes_id) async {
    final db = await DbManager.db();
    final List<Map<String, dynamic>> themeData = await db.query('themes',
        where: "online_id = ?", whereArgs: [themes_id], limit: 1);

    List<Themes> liste = themeData.map((data) => Themes.fromJson(data)).toList();

    return liste.first;
  }


/*------------ Module-----------------*/

  Future<int?> insertDbModule(Modules modules) async {
    final db = await DbManager.db();
    final data = {
      "online_id": modules.online_id,
      "theme_id": modules.theme_id,
      "duration_min": modules.duration_min,
      "language_id": modules.language_id,
      "theme_name": modules.theme_name,
      "title": modules.title,
      "text_content": modules.text_content,
      "audio_content_url": modules.audio_content_url,
      "thumbnail_url": jsonEncode(modules.thumbnail_urls), // ✅ stocker comme JSON
      "language_code": modules.language_code,
      "language_name": modules.language_name,
      "is_completed": modules.is_completed,
    };

    return await db.insert('modules', data);
  }


  Future<void> removeAllDbModule() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('DELETE FROM modules');
  }

  Future<int?> countDbmodules() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('SELECT COUNT(*) FROM modules');
    int? compte = Sqflite.firstIntValue(comptage!);
    return compte;
  }



  Future<List<Modules>> getAllDbmodules() async {
    final db = await DbManager.db();
    List<Map<String, dynamic>> element = await db.query('modules');
    return element.map((data) => Modules.fromMap(data)).toList();
  }

  Future<Modules> getDbmodule(int module_id) async {
    final db = await DbManager.db();
    final List<Map<String, dynamic>> moduleData = await db.query(
      'modules',
      where: "online_id = ?",
      whereArgs: [module_id],
      limit: 1,
    );
    return Modules.fromMap(moduleData.first);
  }

  Future<List<Modules>> getDbmodulebytheme(int theme_id) async {
    final db = await DbManager.db();
    List<Map<String, dynamic>> element = await db.query(
      'modules',
      where: "theme_id = ?",
      whereArgs: [theme_id],
    );
    return element.map((data) => Modules.fromMap(data)).toList();
  }



  /*------------ Exams-----------------*/

  Future<int?> insertDbExame(Exams exames) async {
    int? resultatexame;
    final db = await DbManager.db();
    final data = {
      "online_id": exames.online_id,
      "theme_id": exames.theme_id,
      "passing_score": exames.passing_score,
      "theme_name": exames.theme_name,
      "description": exames.description,
      "title": exames.title,
      "audio_instructions_url": exames.audio_instructions_url,
    };
    resultatexame = await db.insert(
        'exams',
        data
    );
    return resultatexame;
  }

  Future<List<Exams>> getAllDbexams() async {
    final db = await DbManager.db();
    List<Map<String, dynamic>> element = await db.query('exams');
    List<Exams> module = element.map((data) => Exams.fromJson(data)).toList();
    return module;
  }

  Future<void> removeAllDbexams() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('DELETE FROM exams');
  }

  Future<int?> countDbexams() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('SELECT COUNT(*) FROM exams');
    int? compte = Sqflite.firstIntValue(comptage!);
    return compte;
  }
  Future<Exams> getDbexams(exams_id) async {
    final db = await DbManager.db();
    final List<Map<String, dynamic>> moduleData = await db.query('exams',
        where: "online_id = ?", whereArgs: [exams_id], limit: 1);

    List<Exams> liste = moduleData.map((data) => Exams.fromJson(data)).toList();

    return liste.first;
  }

  Future<List<Exams>> getDbexamsbytheme(theme_id) async {
    final db = await DbManager.db();
    List<Map<String, dynamic>> element = await db.query('exams',
        where: "theme_id = ?", whereArgs: [theme_id]);
    List<Exams> module = element.map((data) => Exams.fromJson(data)).toList();
    return module;
  }


  /*------------ Exams question-----------------*/

  Future<int?> insertDbquestion(ExamQuestions exames) async {
    int? resultatexame;
    final db = await DbManager.db();

    // ⚠️ Important : encoder les listes en JSON string
    final data = {
      "online_id": exames.online_id,
      "exam_id": exames.exam_id,
      "theme_id": exames.theme_id,
      "theme_name": exames.theme_name,
      "question_text": exames.question_text,
      "audio_question_url": exames.audio_question_url,
      "is_multiple_choice": exames.is_multiple_choice ? "1" : "0", // ou 1/0 selon ta logique
      "audios": jsonEncode(exames.audios.map((a) => a.toJson()).toList()),
      "answers": jsonEncode(exames.answers.map((a) => a.toJson()).toList()),
    };

    resultatexame = await db.insert('questions', data);
    return resultatexame;
  }


  Future<List<ExamQuestions>> getAllDbExamQuestions() async {
    final db = await DbManager.db();
    List<Map<String, dynamic>> element = await db.query('questions');
    List<ExamQuestions> module = element.map((data) => ExamQuestions.fromJson(data)).toList();
    return module;
  }

  Future<void> removeAllDbexamquestions() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('DELETE FROM questions');
  }

  Future<int?> countDbexamquestions() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('SELECT COUNT(*) FROM questions');
    int? compte = Sqflite.firstIntValue(comptage!);
    return compte;
  }


  Future<ExamQuestions> getDbexamquestions(exams_id) async {
    final db = await DbManager.db();
    final List<Map<String, dynamic>> moduleData = await db.query('questions',
        where: "online_id = ?", whereArgs: [exams_id], limit: 1);

    List<ExamQuestions> liste = moduleData.map((data) => ExamQuestions.fromJson(data)).toList();

    return liste.first;
  }

  Future<List<ExamQuestions>> getDbExamQuestionsbyexam(theme_id) async {
    final db = await DbManager.db();
    List<Map<String, dynamic>> element = await db.query('questions',
        where: "theme_id = ?", whereArgs: [theme_id]);
    List<ExamQuestions> module = element.map((data) => ExamQuestions.fromJson(data)).toList();
    return module;
  }

  /*------------ Exams question-----------------*/

  Future<int?> insertOrUpdateDbexamresults(Result historique) async {
    final db = await DbManager.db();

    final data = {
      "theme_id": historique.theme_id,
      "user_id": historique.user_id,
      "nbr_question": historique.nbr_question,
      "score": historique.score,
      "theme_name": historique.theme_name,
      "created_at": historique.created_at,
      "time": historique.time,
    };

    // 🔎 Vérifier si une ligne avec ce theme_id existe
    final existing = await db.query(
      'examresults',
      where: 'theme_id = ?',
      whereArgs: [historique.theme_id],
    );

    if (existing.isNotEmpty) {
      // 🔄 Met à jour la ligne existante
      final int id = existing.first['id'] as int;
      final rowsUpdated = await db.update(
        'examresults',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
      print("Mise à jour de $rowsUpdated ligne(s) avec id=$id.");
      return id; // retourne l’id mis à jour
    } else {
      // ✅ Insère une nouvelle ligne
      final insertedId = await db.insert('examresults', data);
      print("Insertion d'une nouvelle ligne avec id=$insertedId.");
      return insertedId;
    }
  }



  Future<List<Result>> getAllDbexamresults() async {
    final db = await DbManager.db();
    List<Map<String, dynamic>> element = await db.query('examresults');
    List<Result> module = element.map((data) => Result.fromJson(data)).toList();
    return module;
  }

  Future<void> removeAllDbHistorique() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('DELETE FROM examresults');
  }

  Future<int?> countDbexamresults() async {
    final db = await DbManager.db();
    final comptage = await db.rawQuery('SELECT COUNT(*) FROM examresults');
    int? compte = Sqflite.firstIntValue(comptage!);
    return compte;
  }

  Future<Result> getDbexamresults(exams_id) async {
    final db = await DbManager.db();
    final List<Map<String, dynamic>> moduleData = await db.query('questions',
        where: "online_id = ?", whereArgs: [exams_id], limit: 1);

    List<Result> liste = moduleData.map((data) => Result.fromJson(data)).toList();

    return liste.first;
  }


  // 🔹 Insert
  Future<int> insertIntroduction(Introduction intro) async {
    final db = await DbManager.db();
    return await db.insert(
      'introductions',
      intro.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// 🔹 Get all
  Future<List<Introduction>> getAllIntroductions() async {
    final db = await DbManager.db();
    final List<Map<String, dynamic>> maps = await db.query('introductions');
    return maps.map((map) => Introduction.fromMap(map)).toList();
  }

// 🔹 Get by id local
  Future<Introduction?> getIntroductionById(int id) async {
    final db = await DbManager.db();
    final List<Map<String, dynamic>> maps = await db.query(
      'introductions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Introduction.fromMap(maps.first);
    }
    return null;
  }

// 🔹 Get by online_id
  Future<Introduction?> getIntroductionByOnlineId(int onlineId) async {
    final db = await DbManager.db();
    final List<Map<String, dynamic>> maps = await db.query(
      'introductions',
      where: 'online_id = ?',
      whereArgs: [onlineId],
    );
    if (maps.isNotEmpty) {
      return Introduction.fromMap(maps.first);
    }
    return null;
  }

// 🔹 Update
  Future<int> updateIntroduction(Introduction intro) async {
    final db = await DbManager.db();
    return await db.update(
      'introductions',
      intro.toMap(),
      where: 'id = ?',
      whereArgs: [intro.id],
    );
  }

// 🔹 Delete
  Future<int> deleteIntroduction(int id) async {
    final db = await DbManager.db();
    return await db.delete(
      'introductions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// 🔹 Delete all
  Future<void> clearAllIntroductions() async {
    final db = await DbManager.db();
    await db.delete('introductions');
  }

// 🔹 Count
  Future<int?> countIntroductions() async {
    final db = await DbManager.db();
    final result = await db.rawQuery('SELECT COUNT(*) FROM introductions');
    return Sqflite.firstIntValue(result);
  }



}
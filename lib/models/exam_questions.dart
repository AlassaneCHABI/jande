import 'dart:convert';

class ExamQuestions {
  int id;
  int online_id;
  int exam_id;
  int theme_id;
  String theme_name;
  String question_text;
  String audio_question_url;
  bool is_multiple_choice;

  // Stocké comme JSON string en DB
  final String audiosJson;
  final String answersJson;

  // Objets désérialisés
  late final List<Audio> audios;
  late final List<Answer> answers;

  ExamQuestions({
    required this.id,
    required this.online_id,
    required this.exam_id,
    required this.theme_id,
    required this.theme_name,
    required this.question_text,
    required this.audio_question_url,
    required this.audiosJson,
    required this.answersJson,
    required this.is_multiple_choice,
  }) {
    // On décode les JSON string ici
    answers = _safeJsonDecode(answersJson)
        .map((e) => Answer.fromJson(e))
        .toList();

    audios = _safeJsonDecode(audiosJson)
        .map((e) => Audio.fromJson(e))
        .toList();
  }


  List<dynamic> _safeJsonDecode(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is String) {
      return jsonDecode(decoded) as List<dynamic>;
    } else if (decoded is List) {
      return decoded;
    } else {
      throw Exception("Format JSON inattendu");
    }
  }

  /// Créer depuis un JSON (ex: API)
  factory ExamQuestions.fromJson(Map<String, dynamic> json) {
    return ExamQuestions(
      id: json['id'],
      online_id: json['online_id'],
      exam_id: json['exam_id'],
      theme_id: json['theme_id'],
      theme_name: json['theme_name'],
      question_text: json['question_text'],
      audio_question_url: json['audio_question_url'] ?? '',
      audiosJson: jsonEncode(json['audios']), // Assure un JSON valide
      answersJson: jsonEncode(json['answers']), // Assure un JSON valide
      is_multiple_choice: json['is_multiple_choice'] == true || json['is_multiple_choice'] == 1,
    );
  }

  /// Pour enregistrer dans SQLite
  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'online_id': online_id,
      'exam_id': exam_id,
      'theme_id': theme_id,
      'theme_name': theme_name,
      'question_text': question_text,
      'audio_question_url': audio_question_url,
      'audios': jsonEncode(audios.map((a) => a.toJson()).toList()),
      'answers': jsonEncode(answers.map((a) => a.toJson()).toList()),
      'is_multiple_choice': is_multiple_choice ? 1 : 0,
    };
  }

  /// Depuis SQLite
  factory ExamQuestions.fromDb(Map<String, dynamic> dbJson) {
    return ExamQuestions(
      id: dbJson['id'],
      online_id: dbJson['online_id'],
      exam_id: dbJson['exam_id'],
      theme_id: dbJson['theme_id'],
      theme_name: dbJson['theme_name'],
      question_text: dbJson['question_text'],
      audio_question_url: dbJson['audio_question_url'],
      audiosJson: dbJson['audios'],
      answersJson: dbJson['answers'],
      is_multiple_choice: dbJson['is_multiple_choice'] == 1,
    );
  }
}

// === Classe Audio ===

class Audio {
  final String language_code;
  final String audio_url;
  final int duration_seconds;

  Audio({
    required this.language_code,
    required this.audio_url,
    required this.duration_seconds,
  });

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      language_code: json['language_code'],
      audio_url: json['audio_url'],
      duration_seconds: json['duration_seconds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language_code': language_code,
      'audio_url': audio_url,
      'duration_seconds': duration_seconds,
    };
  }
}

// === Classe Answer ===

class Answer {
  final int id;
  final int online_id;
  final String answer_text;
  final bool is_correct;

  Answer({
    required this.id,
    required this.online_id,
    required this.answer_text,
    required this.is_correct,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      online_id: json['online_id'],
      answer_text: json['answer_text'],
      is_correct: json['is_correct'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'online_id': online_id,
      'answer_text': answer_text,
      'is_correct': is_correct,
    };
  }
}

import 'dart:convert';

class Modules {
  int? id; // id SQLite (AUTO_INCREMENT)
  int online_id, theme_id, duration_min, language_id;
  String theme_name, title, text_content, audio_content_url,
      language_code, language_name, is_completed;
  List<String> thumbnail_urls; // ✅ liste d’images locales ou distantes

  Modules({
    this.id,
    required this.online_id,
    required this.theme_id,
    required this.duration_min,
    required this.language_id,
    required this.theme_name,
    required this.title,
    required this.text_content,
    required this.audio_content_url,
    required this.thumbnail_urls,
    required this.language_code,
    required this.language_name,
    this.is_completed = "Non",
  });

  /// ✅ Depuis API JSON
  /*factory Modules.fromJson(Map<String, dynamic> json) {
    return Modules(
      id: json['id'],
      online_id: json['online_id'],
      theme_id: json['theme_id'],
      duration_min: json['duration_min']??0,
      language_id: json['language_id'],
      theme_name: json['theme_name'] ?? '',
      title: json['title'] ?? '',
      text_content: json['text_content'] ?? '',
      audio_content_url: json['audio_content_url'] ?? '',
      thumbnail_urls: (json['thumbnail_url'] != null)
          ? List<String>.from(jsonDecode(json['thumbnail_url']))
          : [],
      language_code: json['language_code'] ?? '',
      language_name: json['language_name'] ?? '',
      is_completed: json['is_completed'] ?? "Non",
    );
  }*/

  factory Modules.fromJson(Map<String, dynamic> json) {
    return Modules(
      id: json['id'],
      online_id: json['online_id'] ?? 0,
      theme_id: json['theme_id'] ?? 0,
      duration_min: json['duration_min'] ?? 0,
      language_id: json['language_id'] ?? 0,
      theme_name: json['theme_name'] ?? '',
      title: json['title'] ?? '',
      text_content: json['text_content'] ?? '',
      audio_content_url: json['audio_content_url'] ?? '',
      thumbnail_urls: (json['thumbnail_url'] != null)
          ? List<String>.from(jsonDecode(json['thumbnail_url']))
          : [],
      language_code: json['language_code'] ?? '',
      language_name: json['language_name'] ?? '',
      is_completed: json['is_completed'] ?? "Non",
    );
  }


  /// ✅ Pour sauvegarde en DB SQLite
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "online_id": online_id,
      "theme_id": theme_id,
      "duration_min": duration_min,
      "language_id": language_id,
      "theme_name": theme_name,
      "title": title,
      "text_content": text_content,
      "audio_content_url": audio_content_url,
      "thumbnail_url": jsonEncode(thumbnail_urls), // ✅ encodage JSON
      "language_code": language_code,
      "language_name": language_name,
      "is_completed": is_completed,
    };
  }

  /// ✅ Depuis SQLite
  /*factory Modules.fromMap(Map<String, dynamic> map) {
    return Modules(
      id: map['id'],
      online_id: map['online_id'],
      theme_id: map['theme_id'],
      duration_min: map['duration_min']??0,
      language_id: map['language_id'],
      theme_name: map['theme_name'] ?? '',
      title: map['title'] ?? '',
      text_content: map['text_content'] ?? '',
      audio_content_url: map['audio_content_url'] ?? '',
      thumbnail_urls: (map['thumbnail_url'] != null)
          ? List<String>.from(jsonDecode(map['thumbnail_url']))
          : [],
      language_code: map['language_code'] ?? '',
      language_name: map['language_name'] ?? '',
      is_completed: map['is_completed'] ?? "Non",
    );
  }*/

  factory Modules.fromMap(Map<String, dynamic> map) {
    return Modules(
      id: map['id'],
      online_id: map['online_id'] ?? 0,
      theme_id: map['theme_id'] ?? 0,
      duration_min: map['duration_min'] ?? 0,
      language_id: map['language_id'] ?? 0,
      theme_name: map['theme_name'] ?? '',
      title: map['title'] ?? '',
      text_content: map['text_content'] ?? '',
      audio_content_url: map['audio_content_url'] ?? '',
      thumbnail_urls: (map['thumbnail_url'] != null)
          ? List<String>.from(jsonDecode(map['thumbnail_url']))
          : [],
      language_code: map['language_code'] ?? '',
      language_name: map['language_name'] ?? '',
      is_completed: map['is_completed'] ?? "Non",
    );
  }


  /// ✅ Clone modifiable
  Modules copyWith({
    int? id,
    int? online_id,
    int? theme_id,
    int? duration_min,
    int? language_id,
    String? theme_name,
    String? title,
    String? text_content,
    String? audio_content_url,
    List<String>? thumbnail_urls,
    String? language_code,
    String? language_name,
    String? is_completed,
  }) {
    return Modules(
      id: id ?? this.id,
      online_id: online_id ?? this.online_id,
      theme_id: theme_id ?? this.theme_id,
      duration_min: duration_min ?? this.duration_min,
      language_id: language_id ?? this.language_id,
      theme_name: theme_name ?? this.theme_name,
      title: title ?? this.title,
      text_content: text_content ?? this.text_content,
      audio_content_url: audio_content_url ?? this.audio_content_url,
      thumbnail_urls: thumbnail_urls ?? this.thumbnail_urls,
      language_code: language_code ?? this.language_code,
      language_name: language_name ?? this.language_name,
      is_completed: is_completed ?? this.is_completed,
    );
  }
}

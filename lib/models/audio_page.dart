class Introduction {
  int? id; // id local (SQLite)
  int onlineId; // id en ligne (API)
  int languageId;
  String languageName;
  String? titre;
  String codeTitre;
  String pathAudio; // chemin local/serveur
  String pathImage; // chemin local/serveur
  int durationMin;

  Introduction({
    this.id,
    required this.onlineId,
    required this.languageId,
    required this.languageName,
    this.titre,
    required this.codeTitre,
    required this.pathAudio,
    required this.pathImage,
    required this.durationMin,
  });

  /// ✅ Depuis API JSON
  factory Introduction.fromJson(Map<String, dynamic> json) {
    return Introduction(
      id: json['id'],
      onlineId: json['online_id'],
      languageId: json['language_id'],
      languageName: json['language_name'] ?? '',
      titre: json['titre'],
      codeTitre: json['code_titre'] ?? '',
      pathAudio: json['path_audio'] ?? '',
      pathImage: json['path_image'] ?? '',
      durationMin: json['duration_min'] ?? 0,
    );
  }

  /// ✅ Vers DB SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'online_id': onlineId,
      'language_id': languageId,
      'language_name': languageName,
      'titre': titre,
      'code_titre': codeTitre,
      'path_audio': pathAudio,
      'path_image': pathImage,
      'duration_min': durationMin,
    };
  }

  /// ✅ Depuis DB SQLite
  factory Introduction.fromMap(Map<String, dynamic> map) {
    return Introduction(
      id: map['id'],
      onlineId: map['online_id'],
      languageId: map['language_id'],
      languageName: map['language_name'],
      titre: map['titre'],
      codeTitre: map['code_titre'],
      pathAudio: map['path_audio'],
      pathImage: map['path_image'],
      durationMin: map['duration_min'],
    );
  }
}

class Language {
  int id,online_id;
  String code, name;
  int is_active;

  Language(
      this.id,
      this.online_id,
      this.code,
      this.name,
      this.is_active);

  Language.fromJson(Map<String, dynamic> json) :
        id= json['id'],
        online_id= json['online_id'],
        code= json['code'],
        name= json['name'],
        is_active= json['is_active'];
}

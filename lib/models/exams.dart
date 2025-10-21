class Exams {
  int id,online_id,theme_id,passing_score;
  String title, audio_instructions_url,theme_name,description;


  Exams(
      this.id,
      this.online_id,
      this.theme_id,
      this.passing_score,
      this.theme_name,
      this.description,
      this.title,
      this.audio_instructions_url);

  Exams.fromJson(Map<String, dynamic> json) :
        id= json['id'],
        online_id= json['online_id'],
        theme_id= json['theme_id'],
        passing_score= json['passing_score']??0,
        theme_name= json['theme_name'],
        description= json['description'],
        title= json['title'],
        audio_instructions_url= json['audio_instructions_url'];
}

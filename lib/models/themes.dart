class Themes {
  int id,online_id,nbr_modules;
  String title, icon_name,audio_intro_url;

  Themes(
      this.id,
      this.online_id,
      this.nbr_modules,
      this.title,
      this.icon_name,
      this.audio_intro_url,);

  Themes.fromJson(Map<String, dynamic> json) :
        id= json['id'],
        online_id= json['online_id'],
        nbr_modules= json['nbr_modules'],
        title= json['title'],
        icon_name= json['icon_name']??"icone",
        audio_intro_url= json['audio_intro_url']??"audio";
}

class Result {
  int id,theme_id,nbr_question,score,user_id;
  String theme_name, created_at,time;


  Result(
      this.id,
      this.theme_id,
      this.user_id,
      this.nbr_question,
      this.score,
      this.theme_name,
      this.created_at,
      this.time);

  Result.fromJson(Map<String, dynamic> json) :
        id= json['id'],
        theme_id= json['theme_id'],
        user_id= json['user_id'],
        nbr_question = int.parse(json['nbr_question'].toString()),
        score = int.parse(json['score'].toString()),
        theme_name= json['theme_name'],
        created_at= json['created_at'],
        time= json['time'];
}

class ExamResults {
  int id,user_id,exam_id;
  String attempt_date, time_spent_seconds,detail_json;
  double score;
  bool is_synced;



  ExamResults(
      this.id,
      this.user_id,
      this.exam_id,
      this.attempt_date,
      this.time_spent_seconds,
      this.detail_json,
      this.score,
      this.is_synced);

  ExamResults.fromJson(Map<String, dynamic> json) :
        id= json['id'],
        user_id= json['user_id'],
        exam_id= json['exam_id'],
        attempt_date= json['attempt_date'],
        time_spent_seconds= json['time_spent_seconds'],
        detail_json= json['detail_json'],
        score= json['score'],
        is_synced= json['is_synced'];
}

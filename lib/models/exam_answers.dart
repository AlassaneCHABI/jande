class ExamAnswers {
  int id,question_id;
  String answer_text, audio_answer_url;
  bool is_correct;



  ExamAnswers(
      this.id,
      this.question_id,
      this.answer_text,
      this.audio_answer_url,
      this.is_correct);

  ExamAnswers.fromJson(Map<String, dynamic> json) :
        id= json['id'],
        question_id= json['question_id'],
        answer_text= json['answer_text'],
        audio_answer_url= json['audio_answer_url'],
        is_correct= json['is_correct'];
}

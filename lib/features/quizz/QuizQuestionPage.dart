import 'dart:io';

import 'package:jande/features/quizz/felicitation.dart';
import 'package:jande/models/historique.dart';
import 'package:jande/models/users.dart';
import 'package:jande/utils/api_service.dart';
import 'package:jande/utils/constants.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:jande/utils/preference_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import "package:jande/models/exam_questions.dart" as ce_module;
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';

class QuizQuestionPage extends StatefulWidget {
  final int theme_id;
  final String theme_name;
  QuizQuestionPage({Key? key, required this.theme_id,required this.theme_name}) : super(key: key);

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  int _selectedIndex = -1;
  int _currentIndex = 0;
  int _score = 0;
  bool isSpeaking = false;

  ApiService api_service = ApiService();
  DbManager db_manager = DbManager();
  PreferenceManager pref_manager = PreferenceManager();
  List<ce_module.ExamQuestions> liste_module = [];
  final FlutterTts flutterTts = FlutterTts();

  late Result result;
  late User user;

  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  initialise() async{
    result= Result(1,1,1,1,1,"","","");
  }


  Future<void> _getLocalUser() async {

    try {
      final List<User> users = await db_manager.getAllDbUser();
      if (users.isNotEmpty) {
        user = users.first;

        setState(() {}); // Pour refléter les nouvelles valeurs dans l'UI
      }
    } catch (e) {
      print("Erreur lors de la récupération de l'utilisateur : $e");
    } finally {

    }
  }


  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d ?? Duration.zero;
      });
    });

    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });

    _loadQuestions();
    _getLocalUser();
    initialise();
  }

  Future<void> _loadQuestions() async {
    final questions = await getDbLocalQuestion(widget.theme_id);
    setState(() {
      liste_module = questions;
    });

    if (liste_module.isNotEmpty) {
      await loadCurrentAudio(); // <-- charge l'audio de la première question
    }
  }

  Future<List<ce_module.ExamQuestions>> getDbLocalQuestion(int theme_id) async {
    liste_module.clear();
    var curr_liste = await db_manager.getDbExamQuestionsbyexam(theme_id);
    return curr_liste;
  }

  void _onOptionSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _speakSelectedText(String text) async {
    await flutterTts.setLanguage("fr-FR");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  void _goToNextQuestion() {
    _audioPlayer.stop(); // stop audio avant de passer à la suivante
    if (_currentIndex < liste_module.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = -1;
      });
      loadCurrentAudio(); // charger l’audio suivant
    } else {

      final now = DateTime.now();
      final String currentDate = DateFormat('yyyy/MM/dd').format(now);
      final String currentTime = DateFormat('HH:mm:ss').format(now);

      setState(() {
        result.theme_name=widget.theme_name;
        result.score=_score;
        result.nbr_question=liste_module.length;
        result.user_id=user.online_id;
        result.theme_id=widget.theme_id;
        result.created_at=currentDate;
        result.time=currentTime;
        db_manager.insertOrUpdateDbexamresults(result);

      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => FelicitationQuiz(
            score: _score,
            total: liste_module.length,
            theme_name:widget.theme_name,
            theme_id:widget.theme_id
          ),
        ),
      );
    }
  }


  Future<void> loadCurrentAudio() async {
    final currentQuestion = liste_module[_currentIndex];

    if (currentQuestion.audio_question_url.isNotEmpty &&
        File(currentQuestion.audio_question_url).existsSync()) {
      await _audioPlayer.stop(); // stop l’audio précédent
      await _audioPlayer.setFilePath(currentQuestion.audio_question_url);
    } else {
      print("⚠️ Aucun fichier audio trouvé pour cette question.");
    }
  }



  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (liste_module.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = liste_module[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.09,
            vertical: height * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.black, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (_currentIndex + 1) / liste_module.length,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                          minHeight: 20,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${_currentIndex + 1}/${liste_module.length}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 30),

              // Question
              Text(
                currentQuestion.question_text,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Choisissez la bonne réponse",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 25),

              // Options
              ...List.generate(currentQuestion.answers.length, (index) {
                final answer = currentQuestion.answers[index];
                final selected = index == _selectedIndex;
                return GestureDetector(
                  onTap: () => _onOptionSelected(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                      color: selected ? Jaune : const Color(0xFFFAF7EC),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            answer.answer_text,
                            style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Bouton Micro

              Slider(
                activeColor: Colors.black,
                inactiveColor: Colors.grey.shade300,
                value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) {
                  _audioPlayer.seek(Duration(seconds: value.toInt()));
                },
              ),

// Contrôles audio
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _audioPlayer.playing ? Icons.pause_circle : Icons.play_circle,
                      size: 42,
                    ),
                    onPressed: () async {
                      if (_audioPlayer.playing) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.play();
                      }
                    },
                  ),
                ],
              ),


              const Spacer(),

              // Bouton Valider
              SizedBox(
                width: width * 0.9,
                height: 52,
                child: ElevatedButton(
                  onPressed: _selectedIndex != -1
                      ? () {
                    final selectedAnswer = currentQuestion.answers[_selectedIndex];
                    if (selectedAnswer.is_correct) {
                      _score++;
                    }
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _goToNextQuestion();
                    });
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Jaune,
                    textStyle: const TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text(
                    "Valider",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 95, right: 10),
        child: FloatingActionButton.small(
          backgroundColor: isSpeaking ? Colors.black : Colors.black,
          onPressed: () async {
            if (isSpeaking) {
              await flutterTts.stop();
              //await _audioPlayer.stop();
              setState(() {
                isSpeaking = false;
              });
            } else {
              setState(() {
                isSpeaking = true;
              });
              await flutterTts.setLanguage("fr-FR");
              await flutterTts.setPitch(1.0);
              await flutterTts.awaitSpeakCompletion(true);
              await flutterTts.speak(currentQuestion.question_text+"\n Choisissez la bonne réponse");
              for (int i = 0; i < currentQuestion.answers.length; i++) {
                await flutterTts.speak(currentQuestion.answers[i].answer_text);
              }

              setState(() {
                isSpeaking = false;
              });
            }
          },
          child: Icon(
            isSpeaking ? Icons.stop : Icons.mic,
            color: Colors.white,
          ),
        ),
      ),

    );
  }
}

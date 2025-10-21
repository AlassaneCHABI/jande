import 'package:jande/features/auth/register.dart';
import 'package:jande/features/historique.dart';
import 'package:jande/features/quizz/QuizQuestionPage.dart';
import 'package:jande/models/historique.dart';
import 'package:jande/models/language.dart';
import 'package:jande/models/users.dart';
import 'package:jande/utils/api_service.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:jande/utils/preference_manager.dart';
import 'package:jande/widgets/dropdown_widget.dart';
import "package:flutter/material.dart";
import '../../utils/constants.dart';
import 'package:intl/intl.dart';

class FelicitationQuiz extends StatefulWidget {
  final int score;
  final int total;
  final String theme_name;
  final int theme_id;
  const FelicitationQuiz({super.key, required this.score, required this.total,required this.theme_name,required this.theme_id});

  @override
  _FelicitationQuizUIState createState() => new _FelicitationQuizUIState();
}

class _FelicitationQuizUIState extends State<FelicitationQuiz> {
  ApiService api_service = ApiService();
  DbManager db_manager = DbManager();
  PreferenceManager pref_manager = PreferenceManager();


  late Result result;
  late User user;

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
    // TODO: implement initState
    super.initState();
    initialise();
    _getLocalUser();

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.09,
                    vertical: height * 0.03,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.03),
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/felicitation.png',
                          width: width * 0.50,
                          height: width * 0.50,
                        ),
                      ),
                      SizedBox(height: height * 0.05),
                      Center(
                        //alignment: Alignment.center,
                        child:Text(
                          "Score",
                          style: TextStyle(
                            fontSize: width * 0.060,
                            //fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.030),
                      Align(
                        child:
                      Text(
                        widget.score.toString()+"/"+widget.total.toString(),
                        style: TextStyle(
                          fontSize: width * 0.07,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          height: 1,
                        ),
                      ),),


                      SizedBox(height: height * 0.37),
                      Center(
                        child: SizedBox(
                          width: width * 0.9,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {

                              /*final now = DateTime.now();
                              final String currentDate = DateFormat('yyyy/MM/dd').format(now);
                              final String currentTime = DateFormat('HH:mm:ss').format(now);

                             setState(() {
                               result.theme_name=widget.theme_name;
                               result.score=widget.score;
                               result.nbr_question=widget.total;
                               result.user_id=user.online_id;
                               result.theme_id=widget.theme_id;
                               result.created_at=currentDate;
                               result.time=currentTime;
                               db_manager.insertOrUpdateDbexamresults(result);

                             });*/


                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Historique(),
                                ),
                              );

                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Jaune,
                              textStyle: const TextStyle(fontSize: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            child: const Text(
                              'Terminer',
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      onPopInvoked: (didPop) {
        // Bloquer retour
      },
    );
  }
}

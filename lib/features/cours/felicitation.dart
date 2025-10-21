import 'package:jande/features/auth/register.dart';
import 'package:jande/features/quizz/QuizQuestionPage.dart';
import 'package:jande/models/language.dart';
import 'package:jande/widgets/dropdown_widget.dart';
import "package:flutter/material.dart";
import '../../utils/constants.dart';

class Felicitation extends StatefulWidget {
  int theme_id;
  String theme_name;
  Felicitation({Key? key,required this.theme_id,required this.theme_name}) : super(key: key);

  @override
  _FelicitationUIState createState() => new _FelicitationUIState();
}

class _FelicitationUIState extends State<Felicitation> {
  final TextEditingController bailleurcontroller = TextEditingController();
  List<Language> liste_langue = [];

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
                physics: BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.09,
                        vertical: height * 0.03,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // centre verticalement
                        crossAxisAlignment: CrossAxisAlignment.center, // centre horizontalement
                        children: [
                          Image.asset(
                            'assets/images/felicitation.png',
                            width: width * 0.50,
                            height: width * 0.50,
                          ),

                          SizedBox(height: height * 0.05),

                          Text(
                            "Félicitation",
                            style: TextStyle(
                              fontSize: width * 0.07,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: height * 0.030),

                          Text(
                            "Vous avez suivie le module avec brio. A présent vous allez passer un quizz pour tester les notions apprises.",
                            style: TextStyle(
                              fontSize: width * 0.040,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          Spacer(), // pousse le bouton vers le bas si possible

                          SizedBox(
                            width: width * 0.9,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => QuizQuestionPage(theme_id: widget.theme_id,theme_name:widget.theme_name),
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
                                'Commencer le quizz',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: height * 0.03),
                        ],
                      ),
                    ),
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

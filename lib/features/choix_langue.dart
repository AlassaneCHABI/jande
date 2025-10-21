import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jande/features/bienvenue.dart';
import 'package:jande/models/audio_page.dart';
import 'package:jande/models/language.dart';
import 'package:jande/utils/api_service.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:jande/utils/preference_manager.dart';
import 'package:jande/widgets/dropdown_widget.dart';
import "package:flutter/material.dart";
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../utils/constants.dart';

class ChoixLangue extends StatefulWidget {
  ChoixLangue({Key? key}) : super(key: key);

  @override
  _ChoixLangueUIState createState() => new _ChoixLangueUIState();
}

class _ChoixLangueUIState extends State<ChoixLangue> {
  final TextEditingController bailleurcontroller = TextEditingController();
  List<Language> liste_langue = [];
  final FlutterTts flutterTts = FlutterTts();
  String choix_langue="Veuillez choisir la langue dans laquelle vous voulez suivre les formations";
  final _formKey = GlobalKey<FormState>();

  ApiService api_service = ApiService();
  DbManager db_manager = DbManager();
  PreferenceManager pref_manager = PreferenceManager();

  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Introduction? introAudio; // l'introduction à jouer


  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();

    // Écoute les changements de position et durée pour le Slider
    _audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });

    _audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d ?? Duration.zero;
      });
    });

    // ✅ Gérer la fin de lecture
    _audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await _audioPlayer.seek(Duration.zero); // retour au début
        await _audioPlayer.pause();             // stoppe la lecture
        setState(() {
          _position = Duration.zero;
        });
      }
    });


    getDbLocalLangage();
    loadIntroductionAndPlay();
  }


  /// Charger l'introduction "cl" et jouer l'audio
  Future<void> loadIntroductionAndPlay() async {
    introAudio = await getIntroductionByCode('cl');

    if (introAudio != null && introAudio!.pathAudio.isNotEmpty) {
      if (File(introAudio!.pathAudio).existsSync()) {
        await _audioPlayer.setFilePath(introAudio!.pathAudio);
        await _audioPlayer.play(); // joue automatiquement
      } else {
        print("⚠️ Fichier audio introuvable : ${introAudio!.pathAudio}");
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Column(
              children: [
                // Partie scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.09,
                        vertical: height * 0.03,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: height * 0.03),
                          Text(
                            "Choix de la langue",
                            style: TextStyle(
                              fontSize: width * 0.11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              height: 1,
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          Text(
                            "Veuillez choisir la langue dans laquelle vous voulez suivre les formations",
                            style: TextStyle(
                              fontSize: width * 0.050,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: height * 0.03),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                DropdownWidget(
                                  controller: bailleurcontroller,
                                  key: const ValueKey("ActDropButtDomaine"),
                                  child: DropdownButtonFormField(
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    hint: const Text(
                                      'Sélectionnez la langue',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    isExpanded: true,
                                    onChanged: (value) {
                                      setState(() {
                                        pref_manager.setPrefItem('langue', value!.name);
                                        choix_langue = value.name;
                                      });
                                    },
                                    items: liste_langue
                                        .map((item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(item.name),
                                    ))
                                        .toList(),
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Séléctionnez la langue';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      fillColor: Color(0xFFDBC63C).withOpacity(0.10),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide: const BorderSide(color: Colors.black),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: const BorderSide(width: 1.5, color: Colors.black),
                                      ),
                                      hintStyle: const TextStyle(color: Colors.black),
                                      filled: true,
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * 0.2),


                                // ... ton contenu UI
                                if (introAudio != null)
                                  Column(
                                    children: [
                                      Slider(
                                        activeColor: Colors.black,
                                        inactiveColor: Colors.grey.shade300,
                                        value: _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble()),
                                        max: _duration.inSeconds.toDouble(),
                                        onChanged: (value) {
                                          _audioPlayer.seek(Duration(seconds: value.toInt()));
                                        },
                                      ),
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
                                    ],
                                  ),

                                /*Center(
                                  child: IconButton(
                                    iconSize: 80,
                                    icon: const Icon(Icons.mic, color: Colors.blueAccent),
                                    onPressed: () async {
                                      await flutterTts.setLanguage("fr-FR");
                                      await flutterTts.setPitch(1.0);
                                      await flutterTts.speak(choix_langue);
                                    },
                                  ),
                                ),*/
                                SizedBox(height: height * 0.05),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bouton Valider fixé en bas
                Padding(
                  padding: EdgeInsets.only(
                    bottom: height * 0.03,
                    left: width * 0.09,
                    right: width * 0.09,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _audioPlayer.stop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Bienvenue()),
                          );
                        } else {
                          /*await flutterTts.setLanguage("fr-FR");
                          await flutterTts.setPitch(1.0);
                          await flutterTts.speak(choix_langue);*/
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Jaune,
                        textStyle: const TextStyle(fontSize: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text(
                        'Valider',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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

  Future<void> getDbLocalLangage() async {
    try {
      // Vérifier combien de langues sont déjà dans la base
      int? taille_langage = await db_manager.countDbLanguage();
      print("********** Taille Langage: $taille_langage");

      if (taille_langage == 0) {
        // Vider la table avant de recharger
        await db_manager.removeAllDbLanguage();
        List<Language> cette_liste = [];

        try {
          // Appel API
          final response = await api_service.getApi('languages');

          List<dynamic> responseData = response['data'] ?? [];
          if (responseData.isNotEmpty) {
            for (var element in responseData) {
              Language ce_item = Language.fromJson(element);
              await db_manager.insertDbLanguage(ce_item);
              cette_liste.add(ce_item);
            }
          }

          setState(() {
            liste_langue = cette_liste;
          });
        } catch (apiError) {
          print("Erreur API lors du chargement des langues: $apiError");
        }
      } else {
        // Charger depuis la base si déjà présent
        final languesDb = await db_manager.getAllDbLanguage();
        setState(() {
          liste_langue = languesDb;
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des langues: $e");
    }
  }


  Future<Introduction?> getIntroductionByCode(String codeTitre) async {
    try {
      final db = await DbManager.db();
      final List<Map<String, dynamic>> result = await db.query(
        'introductions',          // nom de ta table
        where: 'code_titre = ?',  // condition
        whereArgs: [codeTitre],   // valeur du code
        limit: 1,                 // on veut un seul résultat
      );

      if (result.isNotEmpty) {
        return Introduction.fromMap(result.first);
      } else {
        return null; // Aucun résultat trouvé
      }
    } catch (e) {
      print("❌ Erreur getIntroductionByCode : $e");
      return null;
    }
  }

}

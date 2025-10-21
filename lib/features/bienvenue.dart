import 'dart:io';

import 'package:jande/features/auth/register.dart';
import 'package:jande/models/audio_page.dart';
import 'package:jande/models/language.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:jande/widgets/dropdown_widget.dart';
import "package:flutter/material.dart";
import 'package:just_audio/just_audio.dart';
import '../../utils/constants.dart';

class Bienvenue extends StatefulWidget {
  Bienvenue({Key? key}) : super(key: key);

  @override
  _BienvenueUIState createState() => new _BienvenueUIState();
}

class _BienvenueUIState extends State<Bienvenue> {
  final TextEditingController bailleurcontroller = TextEditingController();
  List<Language> liste_langue = [];


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

    loadIntroductionAndPlay();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Charger l'introduction "cl" et jouer l'audio
  Future<void> loadIntroductionAndPlay() async {
    introAudio = await getIntroductionByCode('bv');

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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Column(
              children: [
                // Contenu scrollable
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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              'assets/Illustration/abc-block.png',
                              width: width * 0.50,
                              height: width * 0.50,
                            ),
                          ),
                          SizedBox(height: height * 0.05),
                          Text(
                            "Bienvenue sur Jande",
                            style: TextStyle(
                              fontSize: width * 0.11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              height: 1,
                            ),
                          ),
                          SizedBox(height: height * 0.030),
                          Text(
                            "Votre application d'apprentissage en langue français et fulfuldé",
                            style: TextStyle(
                              fontSize: width * 0.050,
                            ),
                          ),
                          SizedBox(height: height * 0.03),

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
                        ],
                      ),
                    ),
                  ),
                ),

                // Bouton en bas
                Padding(
                  padding: EdgeInsets.only(
                    bottom: height * 0.03,
                    left: width * 0.09,
                    right: width * 0.09,
                  ),
                  child: SizedBox(
                    width: width * 0.9,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _audioPlayer.stop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Register(),
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

                      child: Text(
                        'Commencer',
                        style: TextStyle(
                          fontSize: width * 0.045,
                          color: Colors.white,
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
    );
  }
}

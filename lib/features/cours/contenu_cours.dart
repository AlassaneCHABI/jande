import 'dart:io';

import 'package:jande/features/cours/felicitation.dart';
import 'package:jande/utils/api_service.dart';
import 'package:jande/utils/constants.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:jande/utils/preference_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import "package:jande/models/modules.dart" as ce_module;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ContenuCours extends StatefulWidget {
  int theme_id;
  String theme_name;
   ContenuCours({Key? key,required this.theme_id,required this.theme_name}) : super(key: key);

  @override
  State<ContenuCours> createState() => _ContenuCoursState();
}

class _ContenuCoursState extends State<ContenuCours> {
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  final FlutterTts flutterTts = FlutterTts();

  List<ce_module.Modules> liste_module = [];
  late Future<List<ce_module.Modules>> future_module;

  ApiService api_service = ApiService();
  DbManager db_manager = DbManager();
  PreferenceManager pref_manager = PreferenceManager();
  int currentIndex = 0;
  bool isSpeaking = false;
  final PageController _pageController = PageController();


  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();

    //_audioPlayer.setAsset('assets/audio/etape1.mp3'); // Ajoutez votre fichier audio ici

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

    getDbLocalModule(widget.theme_id).then((_) {
      if (liste_module.isNotEmpty) {
        loadCurrentAudio(); // charge l'audio du premier module
      }
    });

  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;
    final size = MediaQuery.of(context).size;
    //final width = size.width;
    final height = size.height;
    final module = liste_module.isNotEmpty ? liste_module[currentIndex] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:  module == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.09,
            vertical: height * 0.03,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton retour
              Container(
                width: 40, // Nouvelle largeur plus petite
                height: 40, // Nouvelle hauteur plus petite
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,// Couleur de fond du cercle
                  shape: BoxShape.circle, // Forme circulaire
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black,size: 20,),
                  padding: EdgeInsets.zero, // Padding pour que l'icône soit bien centrée
                  constraints: BoxConstraints(), // Supprime les contraintes par défaut
                ),
              ),
              const SizedBox(height: 20),

              // Étape
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:  Text(
                  "Etape ${currentIndex + 1 < 10 ? '0${currentIndex + 1}' : currentIndex + 1}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Titre
               Text(
                module.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              // Image
              if (module.thumbnail_urls.isNotEmpty) ...[
                Container(
                  height: isTablet ? 300 : 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Jaune, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: module.thumbnail_urls.length,
                      itemBuilder: (context, index) {
                        final path = module.thumbnail_urls[index];
                        return File(path).existsSync()
                            ? Image.file(
                          File(path),
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          "assets/images/chapitre.png", // fallback si fichier manquant
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: module.thumbnail_urls.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: Jaune,
                      dotColor: Colors.grey.shade300,
                    ),
                  ),
                ),
              ] else
                Image.asset(
                  "assets/images/chapitre.png",
                  height: isTablet ? 300 : 200,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 20),

            Expanded(
            child: Scrollbar(
              thumbVisibility: true, // Affiche toujours la barre de défilement
              child: SingleChildScrollView(
                child: Column(
                  children: [
                     Text(
                      module.text_content??"Aucune description disponible.",
                      style: TextStyle(fontSize: 14),
                    ),

                  ],
                ),
              ),
            )
            ),
             // const SizedBox(height: 30),

              // Slider Audio
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
                    icon: const Icon(Icons.skip_previous),
                    onPressed: currentIndex > 0
                        ? () {
                      setState(() {
                        currentIndex--;
                      });
                      loadCurrentAudio(); // audio précédent
                    }
                        : null,
                  ),
                  IconButton(
                    icon: Icon(
                      _audioPlayer.playing ? Icons.pause_circle : Icons.play_circle,
                      size: 42,
                    ),
                    onPressed: () async {
                      if (_audioPlayer.playing) {
                        _audioPlayer.pause();
                      } else {
                        /*await flutterTts.setLanguage("fr-FR");
                        await flutterTts.setPitch(1.0);
                        await flutterTts.speak(module.text_content);*/
                        _audioPlayer.play();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: () {
                      if (currentIndex < liste_module.length - 1) {
                        setState(() {
                          currentIndex++;
                        });
                        loadCurrentAudio(); // audio suivant
                      } else {
                        // Fin du module
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Felicitation(theme_id: widget.theme_id,theme_name:widget.theme_name),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Boutons bas
              Row(
                children: [
                  Expanded(
                            child: ElevatedButton(
                              onPressed: currentIndex > 0
                                  ? () async {  // rendre la fonction async
                                if (isSpeaking) {
                                  await flutterTts.stop();
                                  setState(() {
                                    isSpeaking = false;
                                  });
                                }
                                setState(() {
                                  currentIndex--;
                                });
                                loadCurrentAudio(); // audio précédent
                              }
                                  : null,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        textStyle: const TextStyle(fontSize: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text(
                        "Précédent",
                        style: TextStyle(
                          color: Color(0xFFDBC63C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (currentIndex < liste_module.length - 1) {
                          setState(() {
                            currentIndex++;
                          });
                          loadCurrentAudio();
                          if (isSpeaking) {
                            await flutterTts.stop();
                            //await _audioPlayer.stop();
                            setState(() {
                              isSpeaking = false;
                            });
                          }
                        } else {
                          // Fin du module
                          if (isSpeaking) {
                            await flutterTts.stop();
                            //await _audioPlayer.stop();
                            setState(() {
                              isSpeaking = false;
                            });
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Felicitation(theme_id: widget.theme_id,theme_name:widget.theme_name),
                            ),
                          );
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
                        "Suivant",
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),

                      ),
                    ),
                  ),
                ],
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
              await flutterTts.speak(module!.title+"\n "+module.text_content ?? "");
              //await flutterTts.speak(module.text_content ?? "");
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


  Future<List<ce_module.Modules>> getDbLocalModule(int theme_id) async {

    liste_module.clear();
    var curr_liste = await db_manager.getDbmodulebytheme(theme_id);
    print(curr_liste.length);

    setState(() {
      liste_module = curr_liste;
    });
    return liste_module;
  }

  Future<void> loadCurrentAudio() async {
    final module = liste_module[currentIndex];

    if (module.audio_content_url != null && File(module.audio_content_url!).existsSync()) {
      await _audioPlayer.stop(); // arrête l'audio précédent
      await _audioPlayer.setFilePath(module.audio_content_url!);
    } else {
      print("⚠️ Aucun fichier audio trouvé pour ce module.");
    }
  }


}

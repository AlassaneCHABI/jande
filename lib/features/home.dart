import 'dart:io';

import 'package:jande/features/apropos.dart';
import 'package:jande/features/cours/contenu_cours.dart';
import 'package:jande/features/cours/initialisation.dart';
import 'package:jande/features/cours/modules.dart';
import 'package:jande/features/historique.dart';
import 'package:jande/features/cours/liste_cours.dart';
import 'package:jande/features/profil/profil.dart';
import 'package:jande/models/users.dart';
import 'package:jande/utils/api_service.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:jande/utils/preference_manager.dart';
import 'package:jande/widgets/bottom_nav_bar.dart';
import 'package:jande/widgets/header_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import "package:jande/models/themes.dart" as ce_theme;
import "package:jande/models/historique.dart" as ce_resulat;

import '../models/audio_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  List<ce_theme.Themes> liste_theme = [];
  late Future<List<ce_theme.Themes>> future_theme;
  List<ce_resulat.Result> liste_resultat = [];
  late User user;
  String? first_name ="";

  ApiService api_service = ApiService();
  DbManager db_manager = DbManager();
  PreferenceManager pref_manager = PreferenceManager();

  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Introduction? introAudio; // l'introduction à jouer




  Future<void> _getLocalUser() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      first_name = prefs.getString('first_name');
    });

    /*try {
      final List<User> users = await db_manager.getAllDbUser();
      if (users.isNotEmpty) {
        user = users.first;

        setState(() {}); // Pour refléter les nouvelles valeurs dans l'UI
      }
    } catch (e) {
      print("Erreur lors de la récupération de l'utilisateur : $e");
    } finally {

    }*/
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ListeCours()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Historique()),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ComptePage()),
          );
          break;
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  Future<List<ce_resulat.Result>> getDbLocalResultat() async {
    liste_resultat.clear();
    var curr_liste = await db_manager.getAllDbexamresults();

    setState(() {
      liste_resultat = curr_liste;
    });

    return liste_resultat;
  }






  @override
  void initState() {
    // TODO: implement initState
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
    _getLocalUser();
    getDbLocalTheme();
    _loadHistorique();
  }

  Future<void> _loadHistorique() async {
    await getDbLocalResultat();
  }


  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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


  /// Charger l'introduction "cl" et jouer l'audio
  Future<void> loadIntroductionAndPlay() async {
    introAudio = await getIntroductionByCode('h');

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
      appBar: HeaderMenuWidget(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.09,
          vertical: height * 0.03,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bienvenue ${first_name}",
                style: TextStyle(
                  fontSize: width * 0.07,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: height * 0.005),
              Text(
                "Que veux-tu apprendre aujourd'hui ?",
                style: TextStyle(fontSize: width * 0.04, color: Colors.black54),
              ),
              SizedBox(height: height * 0.03),
              _sectionHeader("Cours populaire", width),
              SizedBox(height: height * 0.015),
              SizedBox(
                height: height*0.23,
                child:liste_theme.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    :  GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: width * 0.03,
                  mainAxisSpacing: height * 0.02,
                  childAspectRatio: 0.85,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: liste_theme.map((theme) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Modules(theme_id: theme.online_id,theme_name: theme.title,)),
                        );
                      },
                      child: _courseCard(theme.title ?? "Thème", theme.icon_name, size,theme.nbr_modules.toString()),
                    );
                  }).toList(),
                )

              ),
              SizedBox(height: height * 0.03),
              _sectionHistorique("Historique", width),
              SizedBox(height: height * 0.02),
              liste_resultat.isEmpty
                  ? const Center(child: Text("Aucun historique disponible."))
                  : Wrap(
                spacing: width * 0.03,
                runSpacing: height * 0.02,
                children: liste_resultat.map((result) {
                  return _historyCard(
                    result.theme_name ?? "Module inconnu",
                    result.created_at ?? "Date inconnue",
                    result.time ?? "Heure inconnue",
                    "${result.score}/${result.nbr_question}",
                    size,
                  );
                }).toList(),
              ),

              //Center(child: Text("Pas de donnée dans votre historique"),)
              /*SizedBox(height: height * 0.015),
              _historyCard("Transformation du savon", "06/05/2025", "13h23", "20/20", size),
              SizedBox(height: height * 0.015),
              _historyCard("Production fourragère", "06/05/2025", "13h09", "20/20", size),*/
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        focusColor: Color(0xFFDBC63C).withOpacity(0.2),
        backgroundColor: Color(0xFFDBC63C).withOpacity(0.2),
        onPressed: () {

        },
        child:IconButton(
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
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _sectionHeader(String title, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.03,
            vertical: width * 0.015,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(width * 0.025),
          ),
          child: InkWell(
            child: Text("Voir tout", style: TextStyle(fontSize: width * 0.03)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ListeCours(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionHistorique(String title, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.03,
            vertical: width * 0.015,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(width * 0.025),
          ),
          child: InkWell(
            child: Text("Voir tout", style: TextStyle(fontSize: width * 0.03)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Historique(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _courseCard(String title, String icon, Size size,String nbr_lecon) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFFDBC63C).withOpacity(0.2),
        borderRadius: BorderRadius.circular(size.width * 0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon != null &&
              File(icon)
                  .existsSync()
              ? Image.file(File(icon),
              width: size.width * 0.1,)
              : const Icon(Icons.play_arrow,
              size: 40, color: const Color(0xFFDBC63C)),
         // Icon(icon, size: size.width * 0.1, color: const Color(0xFFDBC63C)),
          SizedBox(height: size.height * 0.015),
          Text(
            title.length > 30 ? '${title.substring(0, 30)}...' : title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.045,
              height: 1.1,
            ),
          ),
          SizedBox(height: size.height * 0.010),
          Row(
            children: [
              Icon(Icons.menu_book_outlined, size: size.width * 0.05),
              SizedBox(width: size.width * 0.01),
              Text("$nbr_lecon leçons", style: TextStyle(fontSize: size.width * 0.035)),
            ],
          )
        ],
      ),
    );
  }

  Widget _historyCard(String title, String date, String heure, String note, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.035),
      decoration: BoxDecoration(
        color: const Color(0xFFDBC63C).withOpacity(0.2),
        borderRadius: BorderRadius.circular(size.width * 0.02),
      ),
      child: Row(
        children: [
          Icon(Icons.pets, size: size.width * 0.1, color: const Color(0xFFDBC63C)),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.005),
                Row(
                  children: [
                    Text(date, style: TextStyle(fontSize: size.width * 0.03)),
                    SizedBox(width: size.width * 0.02),
                    Text("|", style: TextStyle(fontSize: size.width * 0.03)),
                    SizedBox(width: size.width * 0.02),
                    Text(heure, style: TextStyle(fontSize: size.width * 0.03)),
                    SizedBox(width: size.width * 0.02),
                    Text("|", style: TextStyle(fontSize: size.width * 0.03)),
                    SizedBox(width: size.width * 0.02),
                    Text(
                      note,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.035,
                        color: Colors.green,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<ce_theme.Themes>> getDbLocalTheme() async {

    liste_theme.clear();
    var curr_liste = await db_manager.getAllDbthemes();

    setState(() {
      liste_theme = curr_liste.take(2).toList();
    });
    return liste_theme;
  }


}

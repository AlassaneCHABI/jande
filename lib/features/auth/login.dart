import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jande/features/auth/register.dart';
import 'package:jande/features/home.dart';
import 'package:jande/models/audio_page.dart';
import 'package:jande/models/exam_questions.dart';
import 'package:jande/models/exams.dart';
import 'package:jande/models/modules.dart';
import 'package:jande/models/themes.dart';
import 'package:jande/utils/api_service.dart';
import 'package:jande/utils/auth_service.dart';
import 'package:jande/utils/db_manager.dart';
import 'package:jande/utils/preference_manager.dart';
import "package:flutter/material.dart";
import 'package:just_audio/just_audio.dart';
import '../../utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginUIState createState() => new _LoginUIState();
}

class _LoginUIState extends State<Login> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController= TextEditingController();
  TextEditingController _passwordController= TextEditingController();
  bool passwordVisible = true;
  String messageAlert="Connexion en cours...";

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

    loadIntroductionAndPlay();
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
    introAudio = await getIntroductionByCode('cn');

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
                      Text(
                        "Connexion",
                        style: TextStyle(
                          fontSize: width * 0.11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          height: 1,
                        ),
                      ),
                      SizedBox(height: height * 0.030),
                      Text(
                        "Connectez-vous pour continuer votre apprentissage.",
                        style: TextStyle(
                          fontSize: width * 0.050,
                          //fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: height * 0.03),

                      Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.text,
                                decoration:InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.black)
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(width: 1.5, color: Colors.black),
                                  ),
                                  hintText: "Email",
                                  hintStyle: const TextStyle(color: Colors.black),
                                  alignLabelWithHint: false,
                                  //fillColor: Bleu,
                                  filled: true,
                                  fillColor: Color(0xFFDBC63C).withOpacity(0.10),
                                ),
                                validator: (value) => value!.isEmpty?"Champ incorrect":null,
                              ),
                              SizedBox(height: height * 0.02),
                              TextFormField(
                                controller: _passwordController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(color: Colors.black)
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: const BorderSide(width: 1.5, color: Colors.black),
                                  ),
                                  hintText: "Mot de passe",
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                    color: Jaune,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      passwordVisible ? Icons.visibility_off : Icons.visibility,
                                      color: Jaune,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        passwordVisible = !passwordVisible;
                                      });
                                    },
                                  ),

                                  hintStyle: const TextStyle(color: Colors.black),
                                  alignLabelWithHint: false,
                                  //fillColor: Bleu,
                                  filled: true,
                                  fillColor: Color(0xFFDBC63C).withOpacity(0.10),
                                ),
                                obscureText: passwordVisible,
                                validator: (value) {
                                  if (value == null || value.isEmpty || value.length<8) {
                                    return 'Mot de passe incomplet (min. 8 caractères requis)';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: height * 0.02),
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
                              SizedBox(height: height * 0.04),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Mot de passe oublié'),
                                  SizedBox(width: width * 0.04),
                                ],
                              ),

                              SizedBox(height: height * 0.02),
                              Center(
                                child: SizedBox(
                                  width: width * 0.9,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await _audioPlayer.stop();
                                      if (_formKey.currentState!.validate()) {
                                        loginUserToServer();

                                      }
                                      ;},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Jaune,
                                      textStyle: const TextStyle(fontSize: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                    ),
                                    child: const Text(
                                      'Se connecter',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.03),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      "ou",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: height * 0.02),
                              Center(
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
                                    style:ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      textStyle: const TextStyle(fontSize: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                    ),
                                    child: const Text(
                                      'Créer un compte',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          )),

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



  late StateSetter _setStateDialog;

  void showAlertDialog(BuildContext context, String message) {
    messageAlert = message;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _setStateDialog = setState; // Pour mettre à jour le message plus tard
            return AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text("$messageAlert..."),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  loginUserToServer() async {
    showAlertDialog(context, "Connexion en cours");
    bool isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(_emailController.text.trim());
    bool isPasswordValid = _passwordController.text.trim().length >= 6;

    if (!isEmailValid || !isPasswordValid)
    {
      Navigator.of(context).pop();
      displayDialog(context,
          "Erreur d'authentification",
          "Email et/ou mot de passe incorrect",
          "error");
    }
    else {
      final data = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
      };
      // print(data);

      String response_msg = await AuthService().loginToServer(data);

      if (response_msg.startsWith("succes"))
      {
        await getDbLocalTheme();

      }
      else {
        Navigator.of(context).pop();

        displayDialog(context,
            "Erreur d'authentification",
            "${response_msg}",
            "warning");
      }
    }
  }

/*
  getDbLocalTheme() async {

    _setStateDialog(() {
      messageAlert = "Chargement des Thèmes";
    });

    int? taille_theme=0;
    try {
      db_manager.countDbthemes().then((value) {
        setState(() {
          taille_theme = value;
        });
      });

      print("**********-----Api_service: getDbLocaltheme : taille ");
      print(taille_theme);

      if(taille_theme==0)
      {
        db_manager.removeAllDbthemes();
        taille_theme=0;
        List<Themes> cette_liste = [];

        api_service.getApi('themes').then((value) {
          List<dynamic> responseData = value['data'];
          if(!responseData.isEmpty){
            responseData.forEach((element) {
              Themes ce_item = Themes.fromJson(element);
              db_manager.insertDbTheme(ce_item);
              cette_liste.add(ce_item) ;
            });

            getDbLocalModule();
          }

        });
     }else{
        getDbLocalModule();
      }
    } catch (e) {
      print("*********----ERROR getDbLocalTheme------");
      print(e.toString());
    } finally {

    }
  }
*/

  getDbLocalTheme() async {
    _setStateDialog(() {
      messageAlert = "Chargement des Thèmes";
    });

    try {
      int? taille_theme = await db_manager.countDbthemes();

      print("**********-----Api_service: getDbLocaltheme : taille $taille_theme");

        // Vider la table locale
        await db_manager.removeAllDbthemes();

        // Télécharger depuis l’API
        final value = await api_service.getApi('themes');
        List<dynamic> responseData = value['data'];

        if (responseData.isNotEmpty) {
          List<Themes> cette_liste = [];

          for (var element in responseData) {
            Themes ce_item = Themes.fromJson(element);

            // ✅ Téléchargement et sauvegarde locale de l’icône
            try {
              if (ce_item.icon_name.isNotEmpty) {
                //String localPath = await downloadAndSaveImage(ce_item.icon_name);

                String localPath = await downloadAndSaveFile(
                  Download_File_BASE_URL + ce_item.icon_name,
                  'icone_${ce_item.id}.png',
                );
                ce_item.icon_name = localPath; // on remplace par le chemin local
              }
            } catch (e) {
              print("Erreur lors du téléchargement de l’icône : ${ce_item.icon_name}");
              print(e.toString());
            }

            // Insertion dans la base locale
            await db_manager.insertDbTheme(ce_item);
            cette_liste.add(ce_item);
          }

          print("✅ ${cette_liste.length} thèmes téléchargés et enregistrés.");
        }


      // Ensuite on passe au chargement des modules
      getDbLocalModule();
    } catch (e) {
      print("*********----ERROR getDbLocalTheme------");
      print(e.toString());
    }
  }

  Future<String> downloadAndSaveImage(String url, String filename) async {
    try {
      final dir = await getIntroductionAssetsDirectory(); // 📂 dossier dédié aux introductions
      final filePath = p.join(dir.path, filename);

      final dio = Dio();
      final response = await dio.download(url, filePath);

      if (response.statusCode == 200) {
        print("✅ Fichier téléchargé : $filePath");
        return filePath;
      } else {
        throw Exception('Erreur téléchargement');
      }
    } catch (e) {
      print("❌ Erreur téléchargement fichier : $e");
      return '';
    }
  }


  /*Future<String> downloadAndSaveImage(String url) async {
    final response = await http.get(Uri.parse(BASE_URL+url));

    if (response.statusCode == 200) {
      final documentDir = await getApplicationDocumentsDirectory();
      final fileName = url.split('/').last;
      final file = File('${documentDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      throw Exception('Erreur téléchargement image $url');
    }
  }*/


  Future<void> getDbLocalquestion() async {
    _setStateDialog(() {
      messageAlert = "Chargement des Questions";
    });

    try {
      int? taille_examquestion = await db_manager.countDbexamquestions();
      print("**********-----Api_service: getDbLocalquestion : taille $taille_examquestion");

        await db_manager.removeAllDbexamquestions();
        List<ExamQuestions> cette_liste = [];

        final response = await api_service.getApi('questions');
        List<dynamic> responseData = response['data'] ?? [];

        for (var element in responseData) {
          ExamQuestions ce_item = ExamQuestions.fromJson(element);

          // Téléchargement audio question principale
          if (ce_item.audio_question_url.isNotEmpty) {
            final audioPath = await downloadAndSaveFile(
              Download_File_BASE_URL + ce_item.audio_question_url,
              'question_${ce_item.id}.mp3',
            );
            ce_item.audio_question_url = audioPath;
          }

          // Téléchargement des audios supplémentaires
          for (int i = 0; i < ce_item.audios.length; i++) {
            final audio = ce_item.audios[i];
            final audioPath = await downloadAndSaveFile(
              Download_File_BASE_URL + audio.audio_url,
              'question_${ce_item.id}_${audio.language_code}_$i.mp3',
            );
            ce_item.audios[i] = Audio(
              language_code: audio.language_code,
              audio_url: audioPath,
              duration_seconds: audio.duration_seconds,
            );
          }

          await db_manager.insertDbquestion(ce_item);
          cette_liste.add(ce_item);
        }


      Navigator.of(context).pop();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()),
            (route) => false,
      );
    } catch (e) {
      print("*********----ERROR getDbLocalquestion------");
      print(e.toString());
    }
  }


  getDbLocalexam() async {

    _setStateDialog(() {
      messageAlert = "Chargement des exams";
    });

    int? taille_exams=0;
    try {
      db_manager.countDbexams().then((value) {
        setState(() {
          taille_exams = value;
        });
      });

      print("**********-----Api_service: getDbLocaltheme : taille ");
      print(taille_exams);

        db_manager.removeAllDbexams();
        taille_exams=0;
        List<Exams> cette_liste = [];

        api_service.getApi('exams').then((value) {
          List<dynamic> responseData = value['data'];
          if(!responseData.isEmpty){
            responseData.forEach((element) {
              Exams ce_item = Exams.fromJson(element);
              db_manager.insertDbExame(ce_item);
              cette_liste.add(ce_item) ;
            });

            _setStateDialog(() {
              messageAlert = "Chargement des Examens";
            });
          }

        });
        getDbLocalquestion();

    } catch (e) {
      print("*********----ERROR getDbLocalTheme------");
      print(e.toString());
    } finally {
      /*setState(() {
        _isLoading = false;
      });*/
    }
  }

  getDbLocalModule() async {
    _setStateDialog(() {
      messageAlert = "Chargement des Modules";
    });
    print("Je suis ici");
    try {
      int? tailleModule = await db_manager.countDbmodules();

        await db_manager.removeAllDbModule();
        final response = await api_service.getApi('modules');

        if (response['data'] != null && response['data'].isNotEmpty) {
          List<dynamic> responseData = response['data'];
          List<Modules> modules = [];

          for (var element in responseData) {
            try{
              Modules module = Modules.fromJson(element);

              // Téléchargement de l'image dans le dossier dédié
              // Téléchargement des images
              if (module.thumbnail_urls.isNotEmpty) {
                List<String> localImages = [];
                int index = 0;

                for (var imageUrl in module.thumbnail_urls) {
                  final imagePath = await downloadAndSaveFile(
                    Download_File_BASE_URL+imageUrl, // ⚡ déjà propre
                    'module_${module.id}_$index.png',
                  );
                  localImages.add(imagePath);
                  index++;
                }

                module.thumbnail_urls = localImages; // ✅ remplacer par chemins locaux
              }


              // Téléchargement de l'audio dans le dossier dédié
              if (module.audio_content_url != null) {
                final audioPath = await downloadAndSaveFile(
                  Download_File_BASE_URL + module.audio_content_url!,
                  'module_${module.id}.mp3',
                );

                module.audio_content_url = audioPath;

              }

              await db_manager.insertDbModule(module);
              modules.add(module);
            }catch(e){
              print("Erreur sur module: ${jsonEncode(element)}");
              print("Détail: $e");
            }

          }

          getDbLocalquestion();
          //return modules;
        }


    } catch (e) {
      print("❌ Erreur : $e");
      return [];
    }
  }


  Future<String> downloadAndSaveFile(String url, String filename) async {
    try {
      final dir = await getModulesAssetsDirectory(); // utilise le dossier dédié
      final filePath = p.join(dir.path, filename);

      final dio = Dio();
      final response = await dio.download(url, filePath);

      if (response.statusCode == 200) {
        print("✅ Fichier téléchargé : $filePath");
        return filePath;
      } else {
        throw Exception('Erreur téléchargement');
      }
    } catch (e) {
      print("❌ Erreur téléchargement fichier : $e");
      return '';
    }
  }

  /// Crée  et retourne le chemin vers le dossier `modules_assets`
  Future<Directory> getModulesAssetsDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final modulesDir = Directory(p.join(baseDir.path, 'modules_assets'));

    if (!await modulesDir.exists()) {
      await modulesDir.create(recursive: true);
    }

    return modulesDir;
  }

Future<Directory> getIntroductionAssetsDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final modulesDir = Directory(p.join(baseDir.path, 'introduction_assets'));

    if (!await modulesDir.exists()) {
      await modulesDir.create(recursive: true);
    }

    return modulesDir;
  }

  /// Crée  et retourne le chemin vers le dossier `introduction`
  Future<String> downloadAndSaveIntroductionFile(String url, String filename) async {
    try {
      final dir = await getIntroductionAssetsDirectory(); // 📂 dossier dédié aux introductions
      final filePath = p.join(dir.path, filename);

      final dio = Dio();
      final response = await dio.download(url, filePath);

      if (response.statusCode == 200) {
        print("✅ Fichier téléchargé : $filePath");
        return filePath;
      } else {
        throw Exception('Erreur téléchargement');
      }
    } catch (e) {
      print("❌ Erreur téléchargement fichier : $e");
      return '';
    }
  }


}
